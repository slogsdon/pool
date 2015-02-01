defmodule Pool.UtilTest do
  use ExUnit.Case, async: true

  test "fix_ip/1 when ip is_tuple" do
    opts = [ip: {0,0,0,0}]
    calculated = Pool.Util.fix_ip(opts)
    expected = [:inet, {:ip, {0, 0, 0, 0}}]

    assert calculated == expected
  end

  test "fix_ip/1 when ip is_list" do
    opts = [ip: '0.0.0.0']
    calculated = Pool.Util.fix_ip(opts)
    expected = [:inet, {:ip, {0, 0, 0, 0}}]

    assert calculated == expected
  end

  test "fix_ip/1 when ip is :any" do
    opts = [ip: :any]
    calculated = Pool.Util.fix_ip(opts)
    expected = [:inet, :inet6, {:ip, :any}]

    assert calculated == expected
  end

  test "fix_ip/1 when ip is nil" do
    opts = []
    calculated = Pool.Util.fix_ip(opts)
    expected = [:inet, :inet6, {:ip, :any}]

    assert calculated == expected
  end
end
