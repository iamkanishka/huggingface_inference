defmodule HuggingfaceInference.Utils.Pick do
    @moduledoc """
    Utility functions for data transformation.
    """

    @doc """
    Returns a new map, only keeping the allowlisted properties from the input map.

    ## Parameters
      - `map`: The original map to pick properties from. Must be a map.
      - `keys`: A list of keys to pick. Must be a list of atoms.

    ## Examples

        iex> HuggingfaceInference.Utils.Pick.pick(%{a: 1, b: 2, c: 3}, [:a, :c])
        %{a: 1, c: 3}

        iex> HuggingfaceInference.Utils.Pick.pick(%{x: 42, y: 99}, [:y])
        %{y: 99}

    ## Errors
    Raises `ArgumentError` if `map` is not a map or if `keys` is not a list of atoms.
    """
    @spec pick(map, [atom]) :: map
    def pick(map, keys) when is_map(map) and is_list(keys) do
      try do
        with :ok <- validate_map(map),
             :ok <- validate_keys(keys) do
          Enum.reduce(keys, %{}, fn key, acc ->
            if Map.has_key?(map, key) do
              Map.put(acc, key, Map.get(map, key))
            else
              acc
            end
          end)
        end
      rescue
        e in ArgumentError ->
          IO.puts("Error: #{e.message}")
          raise e
      end
    end

    def pick(_, _), do: raise ArgumentError, "Invalid arguments: expected a map and a list of atoms."

    @doc false
    defp validate_map(map) when is_map(map), do: :ok
    defp validate_map(_), do: raise ArgumentError, "Expected the first parameter to be a map."

    @doc false
    defp validate_keys(keys) when is_list(keys), do: :ok
    defp validate_keys(_), do: raise ArgumentError, "Expected the second parameter to be a list of atoms."
  end
