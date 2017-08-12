defmodule SVG do
  @moduledoc "Main application module."

  @doc """
  Reads a file, then URI-encodes contents,
  prepending "data:image..." markup.
  """
  @spec read_and_uri_encode!(String.t) :: String.t
  def read_and_uri_encode!(path) do
    svg = path
    |> File.read!
    |> URI.encode

    "data:image/svg+xml;charset=UTF-8,#{svg}"
  end

  @doc """
  Reads a file, then base64-encodes contents,
  prepending "data:image..." markup.
  """
  @spec read_and_encode64!(String.t) :: String.t
  def read_and_encode64!(path) do
    svg = path
      |> File.read!
      |> Base.encode64(padding: false)

    "data:image/svg+xml;base64,#{svg}"
  end

  @doc """
  Produces a name for given path to svg,
  by removing the root path from it (second arg),
  and stripping away leading / and extension.

  Example:

      iex> name_from_path("/some/path/images/logo.svg", "/some/path/images")
      "logo"

      iex> name_from_path("/some/path/images/logo.svg", "/some/path")
      "images/logo"
  """
  @spec name_from_path(String.t, String.t) :: String.t
  def name_from_path(path, root) do
    path
    |> String.replace(root, "")
    |> String.split(".")
    |> List.first
    |> String.replace_prefix("/", "")
  end
end
