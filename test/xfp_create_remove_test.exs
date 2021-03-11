Code.require_file("test_util.exs", __DIR__)

defmodule XfpCreateRemoveTest do
  use ExUnit.Case
  doctest Xfp.Application

  @app_name :xfp_app

  # in ms
  @check_state_timeout 10

  setup do
    Application.stop(@app_name)
    :ok = Application.start(@app_name)
    :ok
  end

  test "Create Xfp" do
    assert {:ok, _} = Xfp.Sup.create_xfp()
  end

  test "Create Xfp and Remove XFP" do
    assert {:ok, _} = Xfp.Sup.create_xfp()
    assert nil != Process.whereis(:"Xfp:0")

    assert :ok = Xfp.Sup.remove_xfp()
    assert nil == Process.whereis(:"Xfp:0")
  end

  test "Create Xfp, kill the server and check the supervisor restarts it" do
    assert {:ok, _} = Xfp.Sup.create_xfp(2)
    pid = Process.whereis(:"Xfp:2")
    Process.exit(pid, :kill)
    # sleep to allow the system to crash
    :timer.sleep(100)
    assert nil != Process.whereis(:"Xfp:2")
    assert pid != Process.whereis(:"Xfp:2")
  end

  test "Wait XFP to be inserted" do
    assert {:ok, _} = Xfp.Sup.create_xfp(2)
    assert :ok = TestUtil.wait_xfp_to_be_inserted(2, @check_state_timeout)
    assert :ok = Xfp.Sup.remove_xfp(2)
  end
end
