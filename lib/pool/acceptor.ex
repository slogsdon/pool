defmodule Pool.Acceptor do
  @moduledoc """
  Waits on an open socket until a client connects
  to the socket, the socket is otherwise closed,
  or the process is killed.
  """
  use GenServer

  @type opts      :: Keyword.t
  @type socket    :: :inet.socket
  @type listener  :: pid
  @type transport :: atom
  @type protocol  :: {atom, opts}
  
  @doc """
  Spawns a link to a separate process to accept
  the socket communication
  """
  @spec start_link(socket, listener, transport, protocol, opts) :: pid
  def start_link(socket, listener, transport, protocol, l_opts \\ []) do
    spawn_link(
      __MODULE__,
      :accept,
      [socket,
       listener,
       transport,
       protocol,
       l_opts]
    )
  end

  @doc """
  Accepts on the socket until a client connects.
  """
  @spec accept(socket, listener, transport, protocol, opts) :: no_return
  def accept(socket, listener, transport, {protocol, p_opts}, opts \\ []) do
    timeout = opts[:accept_timeout] || :infinity
    ref = opts[:ref]

    case transport.accept(socket, timeout) do
      {:ok, socket} ->
        case protocol.start_link(ref, transport, socket, p_opts) do
          {:ok, pid} ->
            :ok = transport.controlling_process(socket, pid)
          _ ->
            :ok
        end
        accept(socket, listener, transport, {protocol, p_opts}, opts)
      {:error, reason} when reason in [:timeout, :econnaborted] ->
        accept(socket, listener, transport, {protocol, p_opts}, opts)
      {:error, reason} ->
        exit({:error, reason})
    end
  end
end
