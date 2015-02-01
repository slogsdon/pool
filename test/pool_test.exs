defmodule PoolTest do
  use ExUnit.Case, async: true

  test "start_listener/7" do
    calculated = Pool.start_listener(:echo_test, 2, Pool.Transport.Tcp,
                                     [port: 12345], Test.Fixtures.EchoProtocol,
                                     [], [])

    assert calculated |> elem(0) == :ok
    assert calculated |> elem(1) |> is_pid
  end

  test "start_listener/7 without port" do
    calculated = Pool.start_listener(:ne_test, 2, Pool.Transport.Tcp,
                                     [], Test.Fixtures.EchoProtocol,
                                     [], [])

    assert calculated |> elem(0) == :error
    assert {:badarg, _} = calculated |> elem(1)
  end

  test "stop_listener/1" do
    Pool.start_listener(:stop_test, 2, Pool.Transport.Tcp,
                        [port: 0], Protocol, [], [])
    calculated = Pool.stop_listener(:stop_test)

    assert calculated == :ok
  end

  test "stop_listener/1 with non-existent listener" do
    calculated = Pool.stop_listener(:stop_ne_test)

    assert calculated |> elem(0) == :error
  end

  test "check_spec/2" do
    calculated = Pool.child_spec(:test, [])
    expected = {:test, {Pool.Listener, :start_link, [[]]},
                       :permanent, 5000, :worker, [:test]}

    assert calculated == expected
  end
end
