defmodule Pool.Mixfile do
  use Mix.Project

  def project do
    [ app: :pool,
      version: "0.0.1",
      elixir: "~> 1.0",
      name: "Pool",
      source_url: "https://github.com/slogsdon/pool",
      deps: deps,
      description: description,
      package: package,
      docs: [ readme: "README.md", main: "README" ],
      test_coverage: [ tool: ExCoveralls ] ]
  end

  def application do
    [ applications: [ :logger ],
      mod: { Pool, [] } ]
  end

  defp deps do
    [ { :earmark, "~> 0.1.12", only: :docs },
      { :ex_doc, "~>0.6.2", only: :docs },
      { :excoveralls, "~> 0.3", only: :test },
      { :dialyze, "~> 0.1.3", only: :test } ]
  end

  defp description do
    """
    Socket acceptor pool

    Not ready for use at this time.
    """
  end

  defp package do
    %{ contributors: [ "Shane Logsdon" ],
       licenses: [ "MIT" ],
       links: %{ "GitHub" => "https://github.com/slogsdon/pool" } }
  end
end
