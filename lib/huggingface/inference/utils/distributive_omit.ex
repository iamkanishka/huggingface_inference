defmodule Huggingface.Inference.Utils.DistributiveOmit do
  @moduledoc """
  A utility module for working with maps, including omitting specified keys from maps.
  """

  @spec distributive_omit(map() | nil, list(any()) | nil) :: map()
  @doc """
  Removes specified keys from a map.

  ## Parameters

  - `input_map`: A map from which keys need to be removed.
  - `keys_to_omit`: A list of keys to omit from the map.

  ## Returns

  - A new map with the specified keys removed.

  ## Raises

  - `ArgumentError` if the input map is `nil` or not a valid map.
  - `ArgumentError` if `keys_to_omit` is `nil` or not a valid list.

  ## Examples

      iex> DistributiveOmit.distributive_omit(%{a: 1, b: 2, c: 3}, [:a, :c])
      %{b: 2}

      iex> DistributiveOmit.distributive_omit(%{}, [:a])
      %{}

      iex> DistributiveOmit.distributive_omit(nil, [:a])
      ** (ArgumentError) Input map cannot be nil
  """
  def distributive_omit(input_map, _keys_to_omit) when is_nil(input_map) do
    raise ArgumentError, "Input map cannot be nil"
  end

  def distributive_omit(input_map, _keys_to_omit) when not is_map(input_map) do
    raise ArgumentError, "Input must be a map"
  end

  def distributive_omit(_input_map, keys_to_omit) when is_nil(keys_to_omit) do
    raise ArgumentError, "Keys to omit cannot be nil"
  end

  def distributive_omit(_input_map, keys_to_omit) when not is_list(keys_to_omit) do
    raise ArgumentError, "Keys to omit must be a list"
  end

  def distributive_omit(input_map, keys_to_omit) do
    try do
      Enum.reduce(keys_to_omit, input_map, fn key, acc -> Map.delete(acc, key) end)
    rescue
      exception ->
        raise ArgumentError, "Failed to omit keys: #{Exception.message(exception)}"
    end
  end
end
