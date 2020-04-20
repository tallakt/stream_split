defmodule StreamSplit.Mixfile do
  use Mix.Project

  def project do
    [app: :stream_split,
     description: "Split a stream into a head and tail, without iterating the tail",
     version: "0.1.5",
     elixir: "~> 1.7",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     docs: [main: StreamSplit, extras: ~w(README.md)],
     package: package()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp package do
    [
      maintainers: ["Tallak Tveide"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/tallakt/stream_split",
      },
      files: ~w(lib config mix.exs README.md LICENSE.md),
      build_tools: ~w(mix),
    ]
  end
end
