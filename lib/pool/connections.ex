defmodule Pool.Connections do
  use GenServer
  require Logger

  defmodule State do
    defstruct protocol: nil,
              options: []
  end

  @spec new(pid, Map.t) :: :ok
  def new(pid, socket) do
    Logger.debug "received new connection"
    send pid, {:new_connection, socket, self}
    receive do
      _ -> :ok
    end
  end

  @spec start_link(atom, Keyword.t) :: {:ok, pid}
                                     | {:error, any}
  def start_link(_transport, opts) do
    Logger.debug("starting Connections")
    :proc_lib.start_link(__MODULE__, :init, [self, opts])
  end

  @spec init(pid, Keyword.t) :: {:ok, term}
  def init(parent, opts) do
    Process.flag(:trap_exit, true)
    protocol = opts[:protocol]
    p_opts = (opts[:protocol_opts] || [])
    :ok = :proc_lib.init_ack(parent, {:ok, self})
    State
      |> struct(protocol: protocol, options: p_opts)
      |> loop
  end

  @spec loop(Map.t) :: nil
  def loop(state) do
    receive do
      {:new_connection, socket, caller} ->
        Logger.debug "starting protocol process for new connection"
        case state.protocol.start_link(socket, state.options) do
          {:ok, _pid} ->
            Logger.debug "started"
            # socket control: Acceptor -> Protocol
            # case socket |> Pool.Socket.controlling_process(pid) do
            #   :ok ->
            #     Logger.debug "Protocol has control over connected socket"
                caller |> send(:started)
            #   {:error, _} ->
            #     socket |> Pool.Socket.close
            #     pid |> Process.exit(:kill)
            # end
          _ ->
            Logger.debug "protocol didn't start"
            socket |> Pool.Socket.close
        end
      msg ->
        Log.debug fn ->
          "Connections received #{inspect msg}"
        end
    end
    state |> loop
  end
end
