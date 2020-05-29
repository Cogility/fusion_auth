defmodule FusionAuth.MixProject do
  use Mix.Project

  def project do
    [
      app: :fusion_auth,
      version: "0.1.0",
      elixir: "~> 1.10",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      source_url: "https://github.com/Cogility/fusion_auth",
      docs: [main: "FusionAuth"]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:tesla, "~> 1.3.0"},
      {:hackney, "~> 1.15.2"},
      {:jason, ">= 1.0.0"}
    ]
  end

  defp description() do
    "Elixir SDK for FusionAuth APIs"
  end

  defp package() do
    [
      name: "fusion_auth",
      licenses: ["MIT License"],
      links: %{"GitHub" => "https://github.com/Cogility/fusion_auth"}
    ]
  end
end
