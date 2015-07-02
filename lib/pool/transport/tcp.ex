defmodule Pool.Transport.TCP do
  @moduledoc """
  Implements the `Pool.Socket` protocol TCP connections.
  """
  defstruct socket: nil
end

defimpl Pool.Socket, for: Pool.Transport.TCP do
  import Pool.Util

  @default_opts [ binary: true,
                  backlog: 1024,
                  active: false,
                  packet: :raw,
                  reuseaddr: true,
                  nodelay: true ]

  def listen(socket, port, opts) do
    case :gen_tcp.listen(port, @default_opts
                            |> Keyword.merge(opts)
                            |> Keyword.delete(:ref)
                            |> translate_opts
                            |> fix_ip) do
      {:ok, sock} ->
        %{ socket | socket: sock}
      otherwise ->
        otherwise
    end
  end

  def accept(%{socket: socket}, timeout) do
    :gen_tcp.accept(socket, timeout)
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
