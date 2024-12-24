defmodule Huggingface.Inference.Utils.TypedInclude do
  @moduledoc """
  Utility functions for data checks and transformations.
  """

  @doc """
  Checks if a value is included in a list and ensures it is of the specified type.

  ## Parameters
    - `list`: The list to check. Must be a list of values.
    - `value`: The value to check for inclusion in the list.

  ## Examples

      iex> HuggingfaceInference.Utils.TypedInclude.typed_include([:a, :b, :c], :a)
      true

      iex> HuggingfaceInference.Utils.TypedInclude.typed_include([1, 2, 3], 4)
      false

  ## Errors
  Raises `ArgumentError` if `list` is not a list or if `value` is `nil`.
  """
  @spec typed_include([any()], any()) :: boolean()
  def typed_include(list, value) do
    try do
      with :ok <- validate_list(list),
           :ok <- validate_value(value) do
        Enum.member?(list, value)
      end
    rescue
      e in ArgumentError ->
        IO.puts("Error: #{e.message}")
        raise e
    end
  end

  def typed_include(_, _), do: raise ArgumentError, "Invalid arguments: expected a list and a non-nil value."

  @doc false
  defp validate_list(list) when is_list(list), do: :ok
  defp validate_list(_), do: raise ArgumentError, "Expected the first parameter to be a list."

  @doc false
  defp validate_value(value) when not is_nil(value), do: :ok
  defp validate_value(_), do: raise ArgumentError, "Expected the second parameter to be a non-nil value."
end
