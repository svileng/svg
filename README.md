# SVG  [![hex.pm](https://img.shields.io/hexpm/v/svg.svg?style=flat-square)](https://hex.pm/packages/svg) [![hexdocs.pm](https://img.shields.io/badge/docs-latest-green.svg?style=flat-square)](https://hexdocs.pm/svg)


Tools for caching and serving encoded SVGs for Phoenix.

## Installation

Add to your `mix.exs` as usual:
```elixir
def deps do
  [{:svg, "~> 1.0"}]
end
```
If you're not using [application inference](https://elixir-lang.org/blog/2017/01/05/elixir-v1-4-0-released/#application-inference), then add `:svg` to your `applications` list.

## Replacing urls to SVGs in your CSS

Using the `mix svg.encode` task, all references to svg files in your `priv/static/css` will be replaced with the base64 encoded svg.

For example, if you have an `app.css` file with the following contents:

```css
.foo {
  background-url: url(/icons/add.svg)
}
```

it will be transformed to this:

```css
.foo {
  background-url: url(data:image/svg+xml;base64,PHN2ZyB4bWxucz0ia...)
}
```

By default, task will look for SVGs in the `/priv/static/images` folder.

## Using encoded SVGs at runtime

You need to configure `:svg` in your `config.exs` first:

```elixir
config :svg, otp_app: :my_app # Replace :my_app
```

And then run the background server:

```elixir
defmodule MyApp do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      # .. Ecto, Repo, etc.

      worker(SVG.Server, [])
    ]

    # ...
  end
end
```

The server will build up cache when the main application starts. It will concurrently read all svgs in your `priv/static/images` folder and cache them in memory. You can then use the base64 encoded svgs like so:

```elixir
<img src="<%=raw SVG.Server.get("icons/add") %>">
```

Where `icons/add` corresponds to `priv/static/images/icons/add.svg` on the filesystem. You may want to alias the server when using in templates:

```elixir
alias SVG.Server, as: SVG
```
and then you can use `SVG.get/1` directly.

## Utility functions

See [docs](https://hexdocs.pm/svg/SVG.html) for functions available on the main SVG module.

## Roadmap

- ~~Mix task for replacing svg refs in CSS~~
- Option for URI-encoding instead of Base64
- Option for raw svg output (no encoding, just inline)
- Use SVGO if installed locally

## About

<img src="https://app.heresy.io/images/logo-dark.svg" height="50px">

This project is sponsored by [Heresy](http://heresy.io). We're always looking for great engineers to join our team, so if you love Elixir, open source and enjoy some challenge, drop us a line and say hello!

## License

- svg: See LICENSE file.
- "Heresy" name and logo: Copyright © 2017 Heresy Software Ltd

