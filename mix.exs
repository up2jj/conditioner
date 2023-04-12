defmodule Conditioner.MixProject do
  use Mix.Project
  @version "0.1.0"
  @url_docs "http://hexdocs.pm/conditioner"
  @url_github "https://github.com/up2jj/conditioner"
  def project do
    [
      app: :conditioner,
      name: "Conditioner",
      description: "Conditional logic utility",
      package: %{
        files: [
          "lib",
          "mix.exs",
          "LICENSE"
        ],
        licenses: ["Apache-2.0"],
        links: %{
          "Docs" => @url_docs,
          "GitHub" => @url_github
        },
        source_url: @url_github,
        maintainers: ["Jakub Jasiulewicz"]
      },
      docs: [
        source_ref: "#{@version}",
        source_url: @url_github
      ],
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.29", only: :dev, runtime: false}
    ]
  end
end
