defmodule Pool.Acceptor do
  @moduledoc """
  Waits on an open socket until a client connects
  to the socket, the socket is otherwise closed,
  or the process is killed.
  """
  use GenServer
  require Logger
  @initial_state %{socket: nil, handler: nil}

  def start_link(handler, socket) do
    Logger.debug("starting Acceptor")
    GenServer.start_link(__MODULE__, [handler, socket])
  end

  def init([handler, socket]) do
    Logger.debug("casting accept loop")
    GenServer.cast(self, :accept)
    {:ok, %{@initial_state |
        socket: socket,
        handler: handler
    }}
  end

  def handle_call(_, _from, state) do
    {:noreply, state}
  end

  """
  def handle_cast(:accept, state) do
    Logger.debug("accepting on socket")
    {:ok, socket} = Pool.Socket.accept(state.socket, 5_000)
    Logger.debug("starting another acceptor")
    Pool.Listener.start_acceptor
    Logger.debug("starting handler")
    Pool.Handler.start_link(state.handler, socket)
    {:noreply, state}
  end
  """
  def handle_cast(:accept, state) do
    Logger.debug("accepting on socket")
    case Pool.Socket.accept(state.socket, 5_000) do
      {:ok, socket} ->
        Logger.debug("starting another acceptor")
        Pool.Listener.start_acceptor
        Logger.debug("starting handler")
        Pool.Handler.start_link(state.handler, socket)
      # {:error, :timeout} -> :ok
      otherwise ->
        Logger.debug(fn -> "#{inspect otherwise}" end)
    end
    {:noreply, state}
  end
end
