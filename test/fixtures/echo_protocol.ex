defmodule Test.Fixtures.EchoProtocol do
  @behaviour Pool.Protocol

  def start_link(ref, socket, transport, opts) do
    pid = spawn_link(__MODULE__, :init, [ref, socket, transport, opts])
    {:ok, pid}
  end

  def init(_ref, socket, transport, _opts \\ []) do
    loop(socket, transport)
  end

  defp loop(socket, transport) do
    case transport.receive(socket, 0, 5_000) do
      {:ok, data} ->
        transport.send(socket, data)
        loop(socket, transport)
      _ ->
        :ok = transport.close(socket)
    end
  end
end
