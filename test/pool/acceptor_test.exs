defmodule Pool.AcceptorTest do
  use ExUnit.Case, async: true
  alias Pool.Acceptor
  alias Pool.Transport.Tcp
  alias Test.Fixtures.EchoProtocol

  @tcp_opts [:binary, {:active, false}]

  test "accept/5 without spawn" do
    {:ok, listen} = :gen_tcp.listen(0, @tcp_opts)
    pid = Acceptor.start_link(listen, nil, Tcp, {EchoProtocol, []}, ref: :test_accept)
    {:ok, port} = :inet.port(listen)

    assert pid |> is_pid
    assert pid |> Process.alive?

    {:ok, socket} = :gen_tcp.connect({127,0,0,1}, port, @tcp_opts)
    sent = :gen_tcp.send(socket, "Hi")

    assert pid |> Process.alive?
    assert sent == :ok
  end

  test "accept/5 with timeout" do
    {:ok, listen} = :gen_tcp.listen(0, @tcp_opts)
    pid = Acceptor.start_link(listen, nil, Tcp, {EchoProtocol, []}, ref: :test_accept,
                                                                    accept_timeout: 2000)
    {:ok, port} = :inet.port(listen)

    assert pid |> is_pid
    assert pid |> Process.alive?

    :timer.sleep(2001) # A Space Odessy

    {:ok, socket} = :gen_tcp.connect({127,0,0,1}, port, @tcp_opts)
    sent = :gen_tcp.send(socket, "Hi")

    assert pid |> Process.alive?
    assert sent == :ok
  end

  test "accept/5 with exit" do
    {:ok, listen} = :gen_tcp.listen(0, @tcp_opts)
    pid = Acceptor.start_link(listen, nil, Tcp, {EchoProtocol, []}, ref: :test_accept)

    assert pid |> is_pid
    assert pid |> Process.alive?

    # Trap exits here so the test runner doesn't exit
    Process.flag(:trap_exit, true)
    assert Process.exit(pid, :kill)
    refute pid |> Process.alive?
    assert_received {:'EXIT', ^pid, :killed}
  end
end
