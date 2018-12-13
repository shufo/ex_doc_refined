defmodule ExDocRefined.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_doc_refined,
      version: "0.1.1",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      build_embedded: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {ExDocRefined, {}},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cowboy, "~> 1.0 or ~> 2.0"},
      {:plug, "~> 1.0"},
      {:jason, ">= 0.0.0"},
      {:earmark, "~> 1.0"},
      {:makeup_elixir, "~> 0.10"},
      {:exsync, "~> 0.2", only: :dev},
      {:credo, "~> 0.8", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.19.0", only: :dev}
    ]
  end

  defp description do
    """
    An refined document viewer for Elixir and Phoenix
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*", "priv"],
      maintainers: ["Shuhei Hayashibara"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/shufo/ex_doc_refined",
        "Docs" => "https://hexdocs.pm/ex_doc_refined"
      }
    ]
  end
end
