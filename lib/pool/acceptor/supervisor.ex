defmodule Pool.Acceptor.Supervisor do
  @moduledoc false
  use GenServer
  require Logger

  def start_link(listener, connections, transport, opts) do
    Logger.debug("starting Acceptor.Supervisor")
    Supervisor.start_link(__MODULE__, [listener, connections, transport, opts],
      name: __MODULE__)
  end

  def init([_,_,_,opts] = args) do
    unless opts[:protocol] do
      raise "A protocol is necessary for handling incoming connections"
    end

    children = acceptor_specs(args)
    {:ok, {{:one_for_one, 10, 10}, children}}
  end

  defp acceptor_specs([listener, connections, transport, opts]) do
    t_opts = (opts[:transport_opts] || [])
      |> Keyword.put_new(:num_acceptors, 10)
    protocol = {opts[:protocol], (opts[:protocol_opts] || [])}
    {:ok, socket} = listener |> Pool.Listener.get_socket

    for i <- 1..t_opts[:num_acceptors] do
      child_spec(opts[:ref], i, [socket, connections, transport, protocol, t_opts])
    end
  end

  defp child_spec(ref, i, args) do
    {{Pool.Acceptor, self, i}, {Pool.Acceptor, :start_link, [{ref, i}|args]},
          :permanent, :brutal_kill, :worker, []}
  end
end
