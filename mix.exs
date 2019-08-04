defmodule Fotz.MixProject do
  use Mix.Project

  def project do
    [
      app: :fotz,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      escript: escript(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def escript do
    [
      main_module: Fotz
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:bypass, "~> 1.0", only: :test},
      {:dialyxir, "~> 0.5", only: :dev, runtime: false},
      {:httpoison, "~> 1.4"},
      {:jason, "~> 1.1"},
      {:mockery, "~> 2.3.0", runtime: false},
      {:mustachex, "~> 0.0.2"},
      {:optimus, "~> 0.1.0"}
    ]
  end
end
