defmodule XfpApp.MixProject do
  use Mix.Project

  @source_url "https://github.com/thiagoesteves/xfp_elixir"

  def project do
    [
      app: :xfp_app,
      version: "0.1.0",
      elixir: "~> 1.11",
      name: "xfp_app",
      description: description(),
      source_url: @source_url,
      start_permanent: Mix.env() == :prod,
      compilers: [:elixir_make | Mix.compilers()],
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  # Do not start application during the tests
  defp aliases do
    [
      test: "test --no-start"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :gproc],
      mod: {Xfp.Application, []}
    ]
  end

  defp description do
    "Elixir project for accessing XFP transceivers using Erlang Ports."
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:gproc, git: "https://github.com/uwiger/gproc"},
      {:elixir_make, "~> 0.4", runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:excoveralls, "~> 0.10", only: :test},
      {:meck, "~> 0.9.0", only: :test}
    ]
  end
end
