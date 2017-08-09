defmodule SVG.Server do
  @moduledoc """
  SVG cache and interface for Phoenix.

  To use in templates:

      <img src="<%=raw SVG.Server.get("logo") %>">

  This will fetch "logo.svg" which is relative
  to the priv/static/images folder.

  If that's a bit too long to type, you can
  just alias it for use in view/templates:

      alias SVG.Server, as: SVG

  """
  use GenServer
  require Logger

  @name __MODULE__
  @error_otp_app "SVG.Server requres config :otp_app to be set."

  #
  # Client
  #

  @doc "Starts server."
  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: @name)
  end

  @doc "Lists currently cached resources."
  def list() do
    GenServer.call(@name, :list)
  end

  @doc """
  Get SVG by file name.

  If you need to fetch "icons/add.svg",
  just call "icons/add" (no need for .svg).
  """
  def get(name) do
    GenServer.call(@name, {:get, name})
  end

  #
  # Server
  #

  @doc """
  Initialises the process; reads all svgs in the `priv/static/images`
  folder to build up the cache.
  """
  def init(:ok) do
    Logger.info("SVG.Server initialising")

    otp_app = Application.get_env(:svg, :otp_app, false) || raise @error_otp_app
    images_path = Application.app_dir(otp_app, "priv/static/images/")
    svg_paths = Path.wildcard(images_path <> "/**/*.svg")
    svgs = svg_paths
      |> Task.async_stream(fn path ->
        svg = SVG.read_and_encode64!(path)
        name = SVG.name_from_path(path, images_path)
        %{name: name, svg: svg}
      end)
      |> Enum.map(fn {_, res} -> res end)

    {:ok, svgs}
  end

  @doc false
  def handle_call(:list, _from, cache) do
    {:reply, cache, cache}
  end

  @doc false
  def handle_call({:get, name}, _from, cache) do
    result = Enum.find(cache, nil, &(&1.name == name))
    {:reply, result.svg, cache}
  end
end
