defmodule HttpEchoHandler do
  defstruct options: []
end

defimpl Pool.Handler, for: HttpEchoHandler do
  require Logger
  def start_link(handler, socket) do
    Logger.debug("starting handler")
    pid = spawn_link(__MODULE__, :init, [handler, socket])
    {:ok, pid}
  end

  def init(handler, socket) do
    Logger.debug("starting handler loop")
    loop(handler, socket)
  end

  defp loop(handler, socket) do
    receive_timeout = handler.options[:receive_timeout] || 5_000
    case Pool.Socket.receive(socket, 0, receive_timeout) do
      {:ok, data} ->
        Logger.info("received data")
        Pool.Socket.send(
          socket,
          "HTTP/1.1 200 OK\r\n" <>
          "Content-Length: " <>
          (data |> String.length |> to_string) <>
          "\r\n\r\n" <> data
        )
        loop(handler, socket)
      info ->
        Logger.info("no data to receive. closing socket")
        Logger.info(fn ->
          "#{inspect info}"
        end)
        :ok = Pool.Socket.close(socket)
    end
  end
end
