defmodule Mix.Tasks.Svg.Encode do
  @moduledoc """
  Replaces urls to SVGs in your CSS files
  with the Base64 encoded value.

  By default, it will look at `/priv/static/css`
  for CSS files, and `/priv/static/images` for the SVG files.

  Example CSS (original):

      background-url: url(/icons/add.svg)

  After SVG.Encode:

      background-url: url(data:image/svg+xml;base64,PHN2ZyB4bWxucz0ia...)

  For production deployments, run before `mix phx.digest`.
  """
  use Mix.Task

  @static_dir "priv/static"

  @doc false
  def run(_args) do
    css_paths = Path.wildcard(@static_dir <> "/css/**/*.css")
    svg_paths = Path.wildcard(@static_dir <> "/images/**/*.svg")

    svgs = Enum.map(svg_paths, fn path ->
      data = SVG.read_and_encode64!(path)
      path_name = SVG.name_from_path(path, @static_dir)
      %{path_name: path_name, data: data}
    end)

    Enum.each(css_paths, &(replace_svg_refs(&1, svgs)))

    Mix.shell.info([:green, "[SVG.Encode] Completed."])
  end

  @svg_url_regex ~r{(url\(\s*)(\S+?.svg)(\s*\))}

  defp replace_svg_refs(path, svgs) do
    Mix.shell.info([:cyan, ">> [SVG.Encode] Reading #{path}"])
    content = File.read!(path)
    new_content = Regex.replace(@svg_url_regex, content, fn _, open, url, close ->
      svg = Enum.find(svgs, false, &(String.contains?(url, &1.path_name)))
      if svg do
        Mix.shell.info("[SVG.Encode] Replacing with base64 value: #{url}")
        open <> svg.data <> close
      else
        open <> url <> close
      end
    end)
    File.write!(path, new_content)
  end
end
