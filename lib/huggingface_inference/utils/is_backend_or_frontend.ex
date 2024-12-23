defmodule HuggingfaceInference.Utils.IsBackendOrFrontend do
  @moduledoc """
  Utility module to determine whether the application is running on the backend or frontend
  based on the `APP_ENV` environment variable.

  ## Examples

      iex> HuggingfaceInference.Utils.IsBackendOrFrontend.get_env()
      "Running on the backend" # When APP_ENV is "backend"

      iex> HuggingfaceInference.Utils.IsBackendOrFrontend.get_env()
      "Running on the frontend" # When APP_ENV is "frontend"

      iex> HuggingfaceInference.Utils.IsBackendOrFrontend.get_env()
      ** (RuntimeError) APP_ENV is not set or unrecognized

  """

  @doc """
  Checks the environment (backend or frontend) based on the `APP_ENV` variable.

  ## Parameters

  - `env` (optional): The environment string (e.g., "backend", "frontend"). If `nil`, the value is fetched from `System.get_env("APP_ENV")`.

  ## Returns

  - A string indicating the running environment ("Running on the backend" or "Running on the frontend").

  ## Raises

  - `ArgumentError` if the environment variable is `nil` or unrecognized.

  """
@spec get_env() :: String.t() | nil
  def get_env() do
    env = System.get_env("APP_ENV")

    case env do
      "backend" -> env
      "frontend" -> env
      _ -> IO.puts("Environment not set or unrecognized")
    end
  end
end
