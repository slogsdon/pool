defmodule Pool.Transport.Tcp do
  import Pool.Util

  @behaviour Pool.Transport

  @type port_number :: non_neg_integer
  @type opts        :: Keyword.t
  @type socket      :: :inet.socket
  @type packet      :: term
  @type length      :: non_neg_integer

  @default_opts [ binary: true,
                  backlog: 1024,
                  active: false,
                  packet: :raw,
                  reuseaddr: true,
                  nodelay: true ]

  @spec name :: atom
  def name do
    __MODULE__
  end

  @spec listen(port_number, opts) :: {:ok, socket}
  def listen(port, opts) do
    :gen_tcp.listen(port, @default_opts
                            |> Keyword.merge(opts)
                            |> translate_opts
                            |> fix_ip)
  end

  @spec accept(socket, timeout) :: {:ok, socket}
                                 | {:error, any}
  def accept(socket, timeout) do
    :gen_tcp.accept(socket, timeout)
  end

  @spec close(socket) :: :ok
  def close(socket) do
    :gen_tcp.close(socket)
  end

  @spec send(socket, packet) :: :ok | {:error, atom}
  def send(socket, packet) do
    :gen_tcp.send(socket, packet)
  end

  @spec receive(socket, length, timeout) :: {:ok, any}
                                          | {:error, atom}
  def receive(socket, length, timeout) do
    :gen_tcp.recv(socket, length, timeout)
  end

  @spec controlling_process(socket, pid) :: :ok | {:error, atom}
  def controlling_process(socket, pid) do
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
