defmodule Constantizer.MixProject do
  use Mix.Project

  @version "0.2.0"
  @maintainers ["Aaron Renner"]
  @source_url "https://github.com/aaronrenner/constantizer"

  def project do
    [
      app: :constantizer,
      version: @version,
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),

      # Docs
      name: "Constantizer",
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 0.10", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0.0-rc.3", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false}
    ]
  end

  # Run "mix help docs" to learn about docs
  defp docs do
    [
      main: "Constantizer",
      source_url: @source_url,
      source_ref: "v#{@version}"
    ]
  end

  defp description do
    "Turns functions into constants at compile-time"
  end

  defp package do
    [
      maintainers: @maintainers,
      licenses: ["MIT"],
      links: %{
        "Github" => @source_url
      }
    ]
  end
end
