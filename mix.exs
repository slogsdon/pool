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
      docs: [ readme: "README.md", main: "README" ] ]
  end

  def application do
    [ applications: [ :logger ],
      mod: { Pool, [] } ]
  end

  defp deps do
    []
  end

  defp description do
    """
    Socket acceptor pool
    """
  end

  defp package do
    %{ contributors: ["Shane Logsdon"],
       licenses: ["MIT"],
       links: %{ "GitHub" => "https://github.com/slogsdon/pool" } }
  end
end
