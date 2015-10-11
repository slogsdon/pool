defprotocol Pool.Handler do
  @moduledoc """
  Specification for protocol layers to
  implement for interacting with sockets.
  """

  @type ref       :: atom
  @type socket    :: :inet.socket
  @type transport :: atom
  @type opts      :: Keyword.t

  @doc """
  Should spawn a link to `init/4` and return the
  link's PID.
  """
  @spec start_link(ref, socket, transport, opts) :: {:ok, pid}
  def start_link(ref, socket, transport, opts)

  @doc """
  Should kick off a loop to wait for data. On
  receipt, it should process the incoming data
  and wait for more. When applicable, a response
  should be sent.
  """
  @spec init(ref, socket, transport, opts) :: :ok
  def init(ref, socket, transport, opts)
end
