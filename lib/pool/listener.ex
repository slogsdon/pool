defmodule Pool.Listener do
  @moduledoc """
  Manages a collection of socket acceptors and an
  active listening socket from a transport.
  """
  use GenServer

  defmodule State do
    @moduledoc false
    defstruct socket: nil,
              transport: nil,
              transport_opts: nil,
              acceptors: nil,
              num_acceptors: nil,
              open_reqs: 0,
              max_clients: 0,
              listener_opts: nil,
              protocol: nil
  end

  @doc """
  Inits the listener's state, creating the
  pool of acceptor processes as well.
  """
  @spec init(list) :: {:ok, term}
  def init([num_acceptors, transport, t_opts, protocol, p_opts, l_opts]) do
    Process.flag(:trap_exit, true)

    socket = case t_opts[:socket] do
               nil ->
                 {:ok, sock} = transport.listen(t_opts[:port], t_opts)
                 sock
               sock ->
                 sock
             end

    acceptors = for _ <- 1..num_acceptors do
                  Pool.Acceptor.start_link(
                    socket,
                    self,
                    transport,
                    {protocol, p_opts},
                    l_opts
                  )
                end

    {:ok, %State{ socket: socket,
                  transport: transport,
                  transport_opts: t_opts,
                  acceptors: acceptors,
                  num_acceptors: num_acceptors,
                  open_reqs: 0,
                  max_clients: 300_000,
                  listener_opts: l_opts,
                  protocol: {protocol, p_opts} }}
  end

  @doc """
  On successful start of the listener, send the `pid`
  and `ref` to be tracked by `Pool.Server`.
  """
  @spec start_link(list) :: {:ok, pid}
                          | {:error, any}
  def start_link([_, _, _, _, _, l_opts] = opts) do
    ref = l_opts[:ref]
    case GenServer.start_link(__MODULE__, opts, name: ref) do
      {:ok, pid} ->
        :ok = Pool.Server.set_listener(ref, pid)
        {:ok, pid}
      otherwise ->
        otherwise
    end
  end
end
