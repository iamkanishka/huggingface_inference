defmodule Huggingface.Inference.Utils.Omit do
  @moduledoc """
  Utility module to omit specified keys from a map and return a new map with the remaining keys.

  ## Functions
  - `omit/2`: Removes specified keys from the input map.
  """

  @spec omit(map :: map(), keys :: [atom()] | atom()) :: map()
  def omit(map, keys) do
    with :ok <- validate_inputs(map, keys) do
      try do
        keys_list =
          case keys do
            list when is_list(list) -> list
            key when is_atom(key) -> [key]
          end

        map
        |> Enum.reject(fn {key, _value} -> key in keys_list end)
        |> Enum.into(%{})
      rescue
        exception -> raise ArgumentError, "Error while omitting keys: #{Exception.message(exception)}"
      end
    else
      {:error, reason} -> raise ArgumentError, reason
    end
  end

  @spec validate_inputs(map :: map(), keys :: any()) :: :ok | {:error, String.t()}
  defp validate_inputs(nil, _), do: {:error, "The input map cannot be nil."}
  defp validate_inputs(_, nil), do: {:error, "The keys to omit cannot be nil."}
  defp validate_inputs(map, _) when not is_map(map), do: {:error, "The first argument must be a map."}
  defp validate_inputs(_, keys) when not (is_list(keys) or is_atom(keys)), do: {:error, "The keys must be an atom or a list of atoms."}
  defp validate_inputs(_, _), do: :ok
end
