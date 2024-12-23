defmodule HuggingfaceInference.Utils.Base64FromBytes do
  @moduledoc """
  A utility module for converting a binary (bytes) to its Base64 representation.
  """

  @spec base64_from_bytes(binary() | nil) :: String.t()
  @doc """
  Converts a binary (byte array) to a Base64-encoded string.

  ## Parameters

  - `bytes`: A binary (byte array) to encode.

  ## Returns

  - A Base64-encoded string.

  ## Raises

  - `ArgumentError` if the input is `nil` or not a valid binary.

  ## Examples

      iex> Base64FromBytes.base64_from_bytes(<<72, 101, 108, 108, 111>>)
      "SGVsbG8="

      iex> Base64FromBytes.base64_from_bytes(nil)
      ** (ArgumentError) Input cannot be nil
  """
  def base64_from_bytes(bytes) when is_nil(bytes) do
    raise ArgumentError, "Input cannot be nil"
  end

  def base64_from_bytes(bytes) do
    unless is_binary(bytes) do
      raise ArgumentError, "Input must be a binary (byte array)"
    end

    try do
      :base64.encode(bytes)
    rescue
      exception ->
        raise ArgumentError, "Failed to encode to Base64: #{Exception.message(exception)}"
    end
  end
end
