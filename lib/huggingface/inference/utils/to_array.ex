defmodule Huggingface.Inference.Utils.ToArray do
  @moduledoc """
  Utility functions for data transformation.
  """

  @doc """
  Ensures that the input is returned as a list. If the input is already a list, it is returned unchanged.
  Otherwise, the input is wrapped in a list.

  ## Parameters
    - `input`: The value to be converted into a list. Can be of any type.

  ## Examples

      iex> HuggingfaceInference.Utils.ToArray.to_list(42)
      [42]

      iex> HuggingfaceInference.Utils.ToArray.to_list([1, 2, 3])
      [1, 2, 3]

      iex> HuggingfaceInference.Utils.ToArray.to_list("hello")
      ["hello"]

  ## Errors
  Raises `ArgumentError` if the input is `nil`.
  """
  @spec to_list(any()) :: list()
  def to_list(input) do
    try do
      with :ok <- validate_input(input) do
        if is_list(input) do
          input
        else
          [input]
        end
      end
    rescue
      e in ArgumentError ->
        IO.puts("Error: #{e.message}")
        raise e
    end
  end

  def to_list(_), do: raise(ArgumentError, "Invalid argument: expected a non-nil value.")

  @doc false
  defp validate_input(input) when not is_nil(input), do: :ok
  defp validate_input(_), do: raise(ArgumentError, "Input cannot be nil.")
end
