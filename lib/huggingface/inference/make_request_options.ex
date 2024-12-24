defmodule Huggingface.Inference.MakeRequestOptions do
  @moduledoc """
  A module to prepare request options for the Huggingface Inference API.
  """

  @hf_inference_api_base_url "https://api-inference.huggingface.co"
  @hf_hub_url "https://huggingface.co"

  @type request_args :: %{
          optional(:access_token) => String.t(),
          optional(:endpoint_url) => String.t(),
          optional(:data) => binary(),
          optional(:model) => String.t()
        }

  @type options :: %{
          optional(:force_task) => String.t() | atom(),
          optional(:include_credentials) => boolean() | String.t(),
          optional(:task_hint) => String.t() | atom(),
          optional(:wait_for_model) => boolean(),
          optional(:use_cache) => boolean(),
          optional(:dont_load_model) => boolean(),
          optional(:chat_completion) => boolean(),
          optional(:signal) => reference()
        }

  @spec make_request_options(request_args, options) :: {:ok, %{url: String.t(), info: map()}} | {:error, String.t()}
  def make_request_options(args, options \\\ %{}) do
    with :ok <- ensure_not_nil(args, [:access_token, :model], "Request arguments"),
         :ok <- ensure_not_nil(options, [], "Options"),
         {:ok, model} <- resolve_model(args[:model], args[:endpoint_url], options[:task_hint]),
         {:ok, url} <- resolve_url(model, args[:endpoint_url], options[:force_task]),
         {:ok, headers} <- build_headers(args[:access_token], options),
         {:ok, body} <- build_body(args, options),
         {:ok, credentials} <- resolve_credentials(options[:include_credentials]) do

      info = %{
        headers: headers,
        method: "POST",
        body: body,
        signal: options[:signal]
      }
      info = if credentials, do: Map.put(info, :credentials, credentials), else: info

      {:ok, %{url: url, info: info}}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp ensure_not_nil(params, keys, context) do
    Enum.reduce_while(keys, :ok, fn key, acc ->
      if Map.get(params, key) == nil do
        {:halt, {:error, "#{context}: Missing required parameter: #{key}"}}
      else
        {:cont, acc}
      end
    end)
  end

  defp resolve_model(nil, nil, task_hint) when not is_nil(task_hint) do
    try do
      case HTTPoison.get!("#{@hf_hub_url}/api/tasks") do
        %{status_code: 200, body: body} ->
          {:ok, model} = extract_model_from_task(task_hint, body)
          {:ok, model}
        _ -> {:error, "Unable to fetch default models from Huggingface"}
      end
    rescue
      e -> {:error, "Failed to fetch models for task hint: #{inspect(e)}"}
    end
  end

  defp resolve_model(nil, nil, nil), do: {:error, "No model provided and no default task"}
  defp resolve_model(model, _endpoint, _hint), do: {:ok, model}

  defp resolve_url(model, endpoint, force_task) do
    cond do
      String.starts_with?(model, "http") and endpoint -> {:error, "Both model and endpoint cannot be URLs"}
      String.starts_with?(model, "http") -> {:ok, model}
      endpoint -> {:ok, endpoint}
      true ->
        base_url = if force_task, do: "pipeline/#{force_task}/#{model}", else: "models/#{model}"
        {:ok, "#{@hf_inference_api_base_url}/#{base_url}"}
    end
  end

  defp build_headers(access_token, options) do
    headers =
      if access_token, do: %{"Authorization" => "Bearer #{access_token}"}, else: %{}

    headers =
      if options[:wait_for_model], do: Map.put(headers, "X-Wait-For-Model", "true"), else: headers

    headers =
      if options[:use_cache] == false, do: Map.put(headers, "X-Use-Cache", "false"), else: headers

    headers =
      if options[:dont_load_model], do: Map.put(headers, "X-Load-Model", "0"), else: headers

    {:ok, headers}
  end

  defp build_body(%{data: binary}, _) when is_binary(binary), do: {:ok, binary}
  defp build_body(args, options) do
    try do
      {:ok, args |> Map.drop([:data, :model]) |> Jason.encode!()}
    rescue
      e -> {:error, "Failed to encode request body: #{inspect(e)}"}
    end
  end

  defp resolve_credentials(include_credentials) do
    cond do
      include_credentials == true -> {:ok, "include"}
      is_binary(include_credentials) -> {:ok, include_credentials}
      true -> {:ok, nil}
    end
  end

  defp extract_model_from_task(task_hint, body) do
    tasks = Jason.decode!(body)
    case Map.get(tasks, task_hint) do
      nil -> {:error, "No models available for task hint #{task_hint}"}
      %{models: [%{id: id} | _]} -> {:ok, id}
    end
  end
end
