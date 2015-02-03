defmodule Pool.ServerTest do
  use ExUnit.Case, async: true
  alias Pool.Server

  test "set_listener/2" do
    pid = spawn_link(fn -> :timer.sleep(5000) end)
    calculated = Server.set_listener(:test_set_listener_1, pid)

    assert calculated |> elem(0) == :ok
  end

  test "set_listener/2 with multiple inserts" do
    pid = spawn_link(fn -> :timer.sleep(5000) end)
    calculated1 = Server.set_listener(:test_set_listener_2, pid)
    calculated2 = Server.set_listener(:test_set_listener_2, pid)
    calculated3 = Server.set_listener(:test_set_listener_2, pid)

    assert calculated1 |> elem(0) == :ok
    assert calculated1 |> elem(1) == true
    assert calculated2 |> elem(0) == :ok
    assert calculated2 |> elem(1) == false
    assert calculated3 |> elem(0) == :ok
    assert calculated3 |> elem(1) == false
  end

  test "get_listener/2" do
    pid = spawn_link(fn -> :timer.sleep(5000) end)
    calculated = Server.set_listener(:test_set_listener_3, pid)

    assert calculated |> elem(0) == :ok

    calculated = Server.get_listener(:test_set_listener_3)
    assert calculated == pid
  end

  test "get_listener/2 with dead PID" do
    pid = spawn_link(fn -> :ok end)
    calculated = Server.set_listener(:test_set_listener_4, pid)

    assert calculated |> elem(0) == :ok

    assert_raise ArgumentError, "argument error", fn ->
      Server.get_listener(:test_set_listener_4)
    end
  end
end
