defmodule Pool do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    opts = [strategy: :one_for_one, name: Pool.Supervisor]
    Supervisor.start_link([], opts)
  end

  def new(transport, opts \\ []) do
    import Supervisor.Spec, warn: false

    opts = opts |> Keyword.put_new(:ref, transport)
    args = [transport, opts]

    spec = supervisor(Pool.Listener, args)
    Supervisor.start_child(Pool.Supervisor, spec)
  end
end
