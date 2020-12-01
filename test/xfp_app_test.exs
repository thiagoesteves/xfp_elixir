defmodule XfpAppTest do
  use ExUnit.Case
  doctest Xfp.Application

  test "check Application is running" do
    assert nil != Process.whereis(Xfp.Supervisor)
  end

  test "check Application is already started" do
    assert {:error, {:already_started, _}} = Xfp.Application.start(:none, :none)
  end
end
