defmodule Pool.Transport.TcpTest do
  use ExUnit.Case, async: true
  alias Pool.Transport.Tcp

  test "listen/2" do
    calculated = Tcp.listen(0, [])

    assert calculated |> elem(0) == :ok
  end

  test "listen/2 with :binary option" do
    calculated = Tcp.listen(0, [binary: true, list: false])

    assert calculated |> elem(0) == :ok
  end

  test "listen/2 with :list option" do
    calculated = Tcp.listen(0, [list: true, binary: false])

    assert calculated |> elem(0) == :ok
  end

  test "accept/2 timeout" do
    {:ok, socket} = Tcp.listen(0, [])
    calculated = Tcp.accept(socket, 1)

    assert calculated == {:error, :timeout}
  end

  test "close/1" do
    {:ok, socket} = Tcp.listen(0, [])
    calculated = Tcp.close(socket)

    assert calculated == :ok
  end

  test "receive/3 without accept" do
    {:ok, socket} = Tcp.listen(0, [])
    calculated = Tcp.receive(socket, 0, 0)

    assert calculated == {:error, :enotconn}
  end

  test "controlling_process/2" do
    {:ok, socket} = Tcp.listen(0, [])
    calculated = Tcp.controlling_process(socket, spawn_link(fn -> :ok end))

    assert calculated == :ok
  end
end
