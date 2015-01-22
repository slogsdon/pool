defmodule Pool.Protocol do
  @moduledoc """
  Specification for protocol layers to
  implement for interacting with sockets.
  """
  use Behaviour

  @type ref       :: atom
  @type socket    :: :inet.socket
  @type transport :: atom
  @type opts      :: Keyword.t

  @doc """
  Should spawn a link to `init/4` and return the
  link's PID.
  """
  defcallback start_link(ref, socket, transport, opts) :: {:ok, pid}
  
  @doc """
  Should kick off a loop to wait for data. On
  receipt, it should process the incoming data
  and wait for more. When applicable, a response
  should be sent.
  """
  defcallback init(ref, socket, transport, opts) :: :ok
end
