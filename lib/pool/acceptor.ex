defmodule Pool.Acceptor do
  @moduledoc """
  Waits on an open socket until a client connects
  to the socket, the socket is otherwise closed,
  or the process is killed.
  """

  use GenServer
  require Logger

  @type opts      :: Keyword.t
  @type socket    :: Map.t
  @type transport :: atom
  @type protocol  :: {atom, opts}

  @doc """
  Spawns a link to a separate process to accept
  the socket communication
  """
  @spec start_link({atom, pos_integer}, socket, pid, transport, protocol, opts) :: pid
  def start_link({ref, i}, socket, connections, transport, protocol, opts \\ []) do
    Logger.debug("starting Acceptor")
    GenServer.start_link(__MODULE__, [socket, connections, transport, protocol, opts],
      name: :"#{ref}_#{i}")
  end

  def init(args) do
    {:ok, spawn_link(__MODULE__, :accept, args)}
  end

  @doc """
  Accepts on the socket until a client connects.
  """
  @spec accept(socket, pid, transport, protocol, opts) :: no_return
  def accept(socket, connections, transport, {protocol, p_opts}, opts) do
    Process.flag(:trap_exit, true)
    timeout = opts[:accept_timeout] || :infinity

    case Pool.Socket.accept(socket, timeout) do
      {:ok, sock} ->
        sock = transport |> struct(socket: sock)
        # socket control: Listener -> Acceptor
        case Pool.Socket.controlling_process(sock, self) do
          :ok ->
            Pool.Connections.new(connections, sock)
          {:error, _} -> Pool.Socket.close(sock)
        end
      {:error, :emfile} ->
        receive do
        after 100 -> :ok
        end
      {:error, reason} when reason != :closed ->
        Logger.debug fn -> inspect reason end
        :ok
    end
    flush
    accept(socket, connections, transport, {protocol, p_opts}, opts)
  end

  defp flush do
    receive do
      msg -> Logger.debug(fn ->
              "Acceptor #{inspect self} received #{inspect msg}"
            end)
            flush
    after 0 ->
      :ok
    end
  end
end
