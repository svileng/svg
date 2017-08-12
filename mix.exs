defmodule SVG.Mixfile do
  use Mix.Project

  @version "1.1.0"

  def project do
    [
      app: :svg,
      version: @version,
      elixir: "~> 1.5",
      package: package(),
      name: "SVG",
      description: "Tools for caching/serving encoded SVGs for Phoenix.",
      docs: [
        main: "readme",
        extras: ["README.md"],
        source_url: "https://github.com/heresydev/svg",
        source_ref: @version
      ],
      deps: [
        {:ex_doc, "~> 0.14", only: :dev, runtime: false}
      ]
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp package do
    [
      maintainers: ["Svilen Gospodinov <svilen@heresy.io>"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/heresydev/svg"}
    ]
  end
end
