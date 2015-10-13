defmodule Pool.Listener do
  @moduledoc """
  Manages an active listening socket from a transport.
  """
  use Supervisor
  require Logger

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
    Logger.debug("listening")
    socket = transport
      |> struct(options: opts)
      |> Pool.Socket.listen
    Logger.debug("listened")

    ref = opts[:ref] || transport
    child_opts = [
      #id: Pool.Listener,
      name: ref,
      shutdown: 1_000
    ]
    children = [
      worker(Pool.Acceptor, [struct(HttpEchoHandler), socket], child_opts)
    ]
    spawn_link(fn -> make_children(10) end)
    supervise(children, strategy: :one_for_one)
  end

  def start_acceptor do
    Supervisor.start_child(__MODULE__, [])
  end

  defp make_children(0), do: :ok
  defp make_children(num) do
    start_acceptor
    make_children(num - 1)
  end
end
