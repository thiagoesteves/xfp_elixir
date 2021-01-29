defmodule XfpAppTest do
  use ExUnit.Case
  doctest Xfp.Application

  @app_name :xfp_app

  setup do
    Application.start(@app_name)
    on_exit fn -> Application.stop(@app_name) end
    :ok
  end

  test "check Application is running" do
    assert nil != Process.whereis(Xfp.Supervisor)
  end

  test "check Application is already started" do
    assert {:error, {:already_started, _}} = Xfp.Application.start(:none, :none)
  end
end
