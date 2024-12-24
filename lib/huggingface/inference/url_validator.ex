defmodule Huggingface.Inference.UrlValidator do
  @moduledoc """
  A utility module for validating if a given string is a URL.

  Supports checking both absolute (`http`, `https`) and relative URLs (starting with `/`).
  """

  @doc """
  Checks if the given string is a URL.

  ## Parameters
    - `model_or_url` (String.t): The string to validate.

  ## Returns
    - `true` if the string is a valid URL.
    - `false` otherwise.

  ## Examples

      iex> UrlValidator.is_url("https://example.com")
      true

      iex> UrlValidator.is_url("/relative/path")
      true

      iex> UrlValidator.is_url("not-a-url")
      false

  ## Errors

  Raises `ArgumentError` if the input is `nil` or not a string.
  """
  @spec is_url(String.t()) :: boolean()
  def is_url(nil), do: raise(ArgumentError, "Input cannot be nil")

  def is_url(model_or_url) when is_binary(model_or_url) do
    Regex.match?(~r/^http(s?):/, model_or_url) or String.starts_with?(model_or_url, "/")
  end

  def is_url(_), do: raise(ArgumentError, "Input must be a string")
end
