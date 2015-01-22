defmodule Pool.Transport do
  @moduledoc """
  Specification for transport layers to implement
  for interacting with acceptors.
  """
  use Behaviour

  @type port_number :: non_neg_integer
  @type opts        :: Keyword.t
  @type socket      :: :inet.socket
  @type length      :: non_neg_integer
  @type packet      :: any

  @doc """
  Returns an identifier for the transport.
  """
  defcallback name :: atom

  @doc """
  Sets up a socket to listen on the port Port on the
  local host.

  If `port == 0`, the underlying OS assigns an
  available port number, use `:inet.port/1` to
  retrieve it.

  The available options are:

  * `list: true` - Received `packet` is delivered as
    a list.
  * `binary: true` - Received `packet` is delivered
    as a binary.
  * `backlog: b` - `b` is an integer >= 0. The
    backlog value defaults to 5. The backlog value
    defines the maximum length that the queue of
    pending connections may grow to.
  * `ip: ip_address` - If the host has several
    network interfaces, this option specifies which
    one to listen on.
  * `port: port` - Specify which local port
    number to use.
  * `fd: fd` - If a socket has somehow been
    connected without using `:gen_tcp`, use this
    option to pass the file descriptor for it.
  * `ifaddr: ip_address` - Same as
    `ip: ip_address`. If the host has several
    network interfaces, this option specifies which
    one to use.
  * `inet6: true` - Set up the socket for IPv6.
  * `inet: true` - Set up the socket for IPv4.
  * `tcp_module: module` - Override which
    callback module is used. Defaults to`:inet_tcp`
    for IPv4 and `:inet6_tcp` for IPv6.
  * `opt` - See `:inet.setopts/2` for other options.

  The returned socket `socket` can only be used in
  calls to `accept/2`.
  """
  defcallback listen(port_number, opts) :: {:ok, socket}

  @doc """
  Accepts an incoming connection request on a listen
  socket. `socket` must be a socket returned from
  `listen/2`. `timeout` specifies a timeout value in
  milliseconds, defaults to `:infinity`.

  Returns `{:ok, socket}` if a connection is
  established, or `{:error, :closed}` if `socket` is
  closed, or `{:error, :timeout}` if no connection is
  established within the specified time, or
  `{:error, :system_limit}` if all available ports in
  the Erlang emulator are in use. May also return a
  POSIX error value if something else goes wrong.

  Packets can be sent to the returned `socket` using
  `send/2`. Packets sent from the peer are delivered as
  messages:

      {:tcp, socket, data}

  unless `{:active, false}` was specified in the option
  list for the listen socket, in which case packets are
  retrieved by calling `receive/2`.
  """
  defcallback accept(socket, timeout) :: {:ok, socket}
                                       | {:error, any}

  @doc """
  Closes a socket.
  """
  defcallback close(socket) :: :ok

  @doc """
  Sends a `packet` on a `socket`.
  """
  defcallback send(socket, packet) :: :ok | {:error, atom}

  @doc """
  This function receives a packet from a socket in passive
  mode. A closed socket is indicated by a return value
  `{:error, :closed}`.

  The `length` argument is only meaningful when the socket
  is in raw mode and denotes the number of bytes to read.
  If `length == 0`, all available bytes are returned. If
  `length > 0`, exactly `length` bytes are returned, or an
  error; possibly discarding less than `length` bytes of
  data when the socket gets closed from the other side.

  The optional `timeout` parameter specifies a timeout in
  milliseconds. The default value is `:infinity`.
  """
  defcallback receive(socket, length, timeout) :: {:ok, any}
                                                | {:error, atom}

  @doc """
  Assigns a new controlling process `pid` to `socket`.
  The controlling process is the process which receives
  messages from the socket. If called by any other
  process than the current controlling process,
  `{:error, :not_owner}` is returned.
  """
  defcallback controlling_process(socket, pid) :: :ok | {:error, atom}
end
