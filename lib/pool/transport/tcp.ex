defmodule Pool.Transport.TCP do
  @moduledoc """
  Implements the `Pool.Socket` protocol TCP connections.
  """
  defstruct socket: nil, options: []
end

defimpl Pool.Socket, for: Pool.Transport.TCP do
  import Pool.Util
  require Logger

  @default_opts [ binary: true,
                  backlog: 1024,
                  active: false,
                  packet: :raw,
                  reuseaddr: true,
                  nodelay: true ]

  def listen(socket) do
    options = @default_opts
      |> Keyword.merge(socket.options)
      |> Keyword.delete(:ref)
      |> translate_opts
      |> fix_ip

    Logger.debug("calling :gen_tcp.listen/2")
    result = :gen_tcp.listen(socket.options[:port], options)

    case result do
      {:ok, sock} ->
        %{ socket | socket: sock}
      otherwise ->
        otherwise
    end
  end

  def accept(%{socket: socket}, timeout) do
    Logger.debug("calling :gen_tcp.accept/2")
    case :gen_tcp.accept(socket, timeout) do
      {:ok, s} ->
        {:ok, %{socket | socket: s}}
      otherwise ->
        otherwise
    end
  end

  def close(%{socket: socket}) do
    :gen_tcp.close(socket)
  end

  def send(%{socket: socket}, packet) do
    :gen_tcp.send(socket, packet)
  end

  def receive(%{socket: socket}, length, timeout) do
    :gen_tcp.recv(socket, length, timeout)
  end

  def controlling_process(%{socket: socket}, pid) do
    :gen_tcp.controlling_process(socket, pid)
  end

  defp translate_opts(opts) do
    options = []

    if opts[:binary] == true do
      options = [:binary|options]
    else
      if opts[:list] == true do
        options = [:list|options]
      end
    end

    opts = opts
      |> Keyword.delete(:binary)
      |> Keyword.delete(:list)
    options ++ for {k, v} <- opts, do: {k, v}
  end
end
