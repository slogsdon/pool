defmodule Pool do
  use Application
  require Logger

  @doc """
  Application callback for `start/2`.

  Creates a new ets table for storing atom-based
  references and matching listener PIDs for
  `Pool.Server`, and adds `Pool.Server` as a
  child to the application's supervision tree.
  """
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    Logger.debug("creating ETS table")
    Pool.Server = :ets.new(Pool.Server, [:ordered_set,
                                         :public,
                                         :named_table])

    children = [
      worker(Pool.Server, [])
    ]

    Logger.debug("starting supervisor")
    opts = [strategy: :one_for_one, name: Pool.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @doc """
  Starts a new listener as a child in the
  application's supervision tree.
  """
  @spec start_listener(atom, integer, any, any, any, any, any) :: {:ok, pid}
                                                               | {:error, term}
  def start_listener(ref, num_acceptors, transport, t_opts, protocol, p_opts \\ [], l_opts \\ []) do
    Logger.debug("starting for #{ref}")
    _ = Code.ensure_loaded(transport)

    l_opts = [{:ref, ref} | l_opts]
    socket = t_opts[:socket]
    spec = child_spec(ref, [num_acceptors, transport, t_opts,
                            protocol, p_opts, l_opts])

    Logger.debug("starting listener child")
    case Supervisor.start_child(Pool.Supervisor, spec) do
      {:ok, pid} when socket != nil ->
        Logger.debug("updating controlling process for socket #{inspect socket}")
        transport.controlling_process(socket, pid)
        {:ok, pid}
      otherwise ->
        otherwise
    end
  end

  @doc """
  Stops a listener, and removes it from the
  supervision tree.
  """
  @spec stop_listener(atom) :: :ok | {:error, term}
  def stop_listener(ref) do
    Logger.debug("stopping listener child")
    case Supervisor.terminate_child(Pool.Supervisor, ref) do
      :ok -> Supervisor.delete_child(Pool.Supervisor, ref)
      otherwise -> otherwise
    end
  end

  @doc """
  Creates a proper child worker spec to be
  inserted into the supervision tree.
  """
  @spec child_spec(atom, any) :: any
  def child_spec(ref, opts) do
    {ref, {Pool.Listener, :start_link, [opts]},
          :permanent, 5000, :worker, [ref]}
  end
end
