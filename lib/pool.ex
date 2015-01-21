defmodule Pool do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # worker(Pool.Worker, [arg1, arg2, arg3])
    ]

    opts = [strategy: :one_for_one, name: Pool.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
