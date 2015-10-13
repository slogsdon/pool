defprotocol Pool.Handler do
  @moduledoc """
  Specification for protocol layers to
  implement for interacting with sockets.
  """

  alias Pool.Socket

  @doc """
  Should spawn a link to `init/4` and return the
  link's PID.
  """
  @spec start_link(t, Socket.t) :: {:ok, pid}
  def start_link(handler, socket)

  @doc """
  Should kick off a loop to wait for data. On
  receipt, it should process the incoming data
  and wait for more. When applicable, a response
  should be sent.
  """
  @spec init(t, Socket.t) :: :ok
  def init(handler, socket)
end
