defmodule XfpApp.MixProject do
  use Mix.Project

  def project do
    [
      app: :xfp_app,
      version: "0.1.0",
      elixir: "~> 1.11",
      name: "xfp_app",
      description: description(),
      source_url: "https://github.com/thiagoesteves/xfp_elixir",
      start_permanent: Mix.env() == :prod,
      compilers: [:elixir_make | Mix.compilers],
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Xfp.Application, []},
      applications: [:gproc]
    ]
  end

  defp description do
    "Elixir access to XFP transceivers using Erlang Ports."
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:gproc, git: "git://github.com/uwiger/gproc"},
      {:elixir_make, "~> 0.4", runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
    ]
  end
end
