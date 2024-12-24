defmodule Huggingface.Inference.GetDefaultTask do
  @moduledoc """
  Provides functionality to fetch the default task for a model from the Hugging Face Hub.
  Implements caching to minimize API calls.
  """
  alias HuggingfaceInference.UrlValidator

  @hf_hub_url "https://huggingface.co"
  @cache_duration :timer.minutes(10)
  @max_cache_items 1000

  @type default_task_options :: %{fetch: (String.t() -> {:ok, any} | {:error, any})}

  @doc """
  Get the default task for a model. Uses a cache with 10-minute expiration and maximum size of 1000 items.

  ## Parameters
  - `model` (String.t()): The name of the model.
  - `access_token` (String.t() | nil): The access token for authentication (if required).
  - `options` (map): Optional fetch function.

  ## Returns
  - `{:ok, task}`: The default task for the model.
  - `{:error, reason}`: Error if fetching or processing fails.
  """
  @spec get_default_task(String.t(), String.t() | nil, default_task_options()) ::
          {:ok, String.t()} | {:error, any}
  def get_default_task(model, access_token, options \\ %{}) do
    if UrlValidator.is_url(model) do
      with :ok <- validate_parameters(model, access_token),
           cache_key <- generate_cache_key(model, access_token),
           {:ok, task} <- fetch_or_get_cached_task(cache_key, model, access_token, options) do
        {:ok, task}
      else
        {:error, reason} -> {:error, reason}
      end
    else
      {:error, "Model should not be empty"}
    end
  end

  defp validate_parameters(nil, _), do: {:error, "Model name cannot be nil."}
  defp validate_parameters(_, nil), do: {:error, "Access token cannot be nil."}
  defp validate_parameters(_, _), do: :ok

  defp generate_cache_key(model, access_token) do
    "#{model}:#{access_token}"
  end

  defp fetch_or_get_cached_task(cache_key, model, access_token, options) do
    case get_cached_task(cache_key) do
      {:ok, task} ->
        {:ok, task}

      :not_found ->
        case fetch_task_from_hub(model, access_token, options) do
          {:ok, task} ->
            put_task_in_cache(cache_key, task)
            {:ok, task}

          {:error, reason} ->
            {:error, reason}
        end
    end
  end

  defp get_cached_task(cache_key) do
    case :ets.lookup(:task_cache, cache_key) do
      [{^cache_key, %{task: task, date: date}}] ->
        if DateTime.diff(DateTime.utc_now(), date, :millisecond) <= @cache_duration do
          {:ok, task}
        else
          :not_found
        end

      _ ->
        :not_found
    end
  end

  defp put_task_in_cache(cache_key, task) do
    :ets.insert(:task_cache, {cache_key, %{task: task, date: DateTime.utc_now()}})

    if :ets.info(:task_cache, :size) > @max_cache_items do
      [{oldest_key, _} | _] =
        :ets.tab2list(:task_cache) |> Enum.sort_by(fn {_k, v} -> v.date end, :asc)

      :ets.delete(:task_cache, oldest_key)
    end
  end

  defp fetch_task_from_hub(model, access_token, options) do
    url = "#{@hf_hub_url}/api/models/#{model}?expand[]=pipeline_tag"
    headers = if access_token, do: [Authorization: "Bearer #{access_token}"], else: []

    fetch_fn = options[:fetch] || (&HTTPoison.get/2)

    try do
      case fetch_fn.(url, headers) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          body
          |> Jason.decode()
          |> case do
            {:ok, %{"pipeline_tag" => task}} -> {:ok, task}
            _ -> {:error, "Invalid response from API."}
          end

        {:ok, %HTTPoison.Response{status_code: code}} ->
          {:error, "HTTP error: #{code}"}

        {:error, reason} ->
          {:error, reason}
      end
    rescue
      e -> {:error, "Exception while fetching task: #{inspect(e)}"}
    end
  end

  @doc """
  Initializes the ETS table for caching tasks. This function should be called once at the application start.
  """
  def init_cache do
    :ets.new(:task_cache, [:named_table, :public, :set, {:read_concurrency, true}])
  end
end
