defmodule Pool.Listener do
  @moduledoc """
  Manages an active listening socket from a transport.
  """
  use GenServer
  require Logger

  @spec get_socket(pid, pos_integer | :infinity) :: {:ok, Map.t}
  def get_socket(pid, timeout \\ 5_000) do
    GenServer.call(pid, :get_socket, timeout)
  end

  @spec start_link(atom, Keyword.t) :: {:ok, pid}
                                     | {:error, any}
  def start_link(transport, opts) do
    Logger.debug("starting Listener")
    ref = opts[:ref] || transport
    Supervisor.start_link(__MODULE__, [transport, opts], name: ref)
  end

  ## callbacks

  @spec init([atom | [Keyword.t]]) :: {:ok, term}
  def init([transport, opts]) do
    ref = opts[:ref] || transport
    l_opts = (opts[:listener_opts] || [])
      |> Keyword.put(:ref, ref)

    Code.ensure_loaded(transport)

    socket = transport
      |> struct
      |> Pool.Socket.listen(l_opts[:port], l_opts)

    {:ok, socket}
  end

  def handle_call(:get_socket, _from, socket) do
    {:reply, {:ok, socket}, socket}
  end
end
