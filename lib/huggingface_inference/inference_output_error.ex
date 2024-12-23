defmodule HuggingfaceInference.InferenceOutputError do
  @moduledoc """
  Represents an error when inference output is invalid.

  This exception is raised when the output of an inference operation does not meet expected criteria.
  """

  @type t :: %__MODULE__{
          message: String.t()
        }

  @enforce_keys [:message]
  defexception [:message]

  @doc """
  Creates a new `InferenceOutputError` instance.

  ## Parameters
    - `message` (String.t): The error message describing the invalid inference output.

  ## Examples

      iex> raise InferenceOutputError.new("Invalid data format")
      ** (InferenceOutputError) Invalid inference output: Invalid data format. Use the 'request' method with the same parameters to do a custom call with no type checking.
  """
  @spec new(String.t() | nil) :: t()
  def new(nil), do: raise ArgumentError, "Message cannot be nil"
  def new(message) when is_binary(message) do
    %__MODULE__{
      message: "Invalid inference output: #{message}. Use the 'request' method with the same parameters to do a custom call with no type checking."
    }
  end

  @impl true
  def exception(%{message: nil}), do: raise ArgumentError, "Message cannot be nil"
  def exception(%{message: message}) when is_binary(message) do
    %__MODULE__{
      message: "Invalid inference output: #{message}. Use the 'request' method with the same parameters to do a custom call with no type checking."
    }
  end

  @impl true
  def message(%__MODULE__{message: message}), do: message
end
