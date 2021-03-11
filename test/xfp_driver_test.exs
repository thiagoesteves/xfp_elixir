defmodule XfpDriver do
  use ExUnit.Case
  doctest Xfp.Application

  @app_name :xfp_app
  @test_pin 2
  @test_register 20
  @test_values 55

  setup do
    Application.start(@app_name)
    on_exit(fn -> Application.stop(@app_name) end)
    :ok
  end

  test "Check Xfp.Driver is supervised" do
    assert pid = Process.whereis(Xfp.Driver)
    Process.exit(pid, :kill)
    # sleep to allow the system to crash
    :timer.sleep(100)
    assert nil != Process.whereis(Xfp.Driver)
    assert pid != Process.whereis(Xfp.Driver)
  end

  test "Check read/write register" do
    assert {:ok, val} = Xfp.Driver.read_register(0, @test_register)
    assert {:ok, 0} = Xfp.Driver.write_register(0, @test_register, @test_values)
    assert {:ok, @test_values} = Xfp.Driver.read_register(0, @test_register)
    assert @test_values != val
  end

  test "Check read/write pin" do
    assert {:ok, 0} = Xfp.Driver.write_pin(0, @test_pin, 0)
    assert {:ok, 0} = Xfp.Driver.read_pin(0, @test_pin)
    assert {:ok, 0} = Xfp.Driver.write_pin(0, @test_pin, 1)
    assert {:ok, 1} = Xfp.Driver.read_pin(0, @test_pin)
    assert {:ok, 0} = Xfp.Driver.write_pin(0, @test_pin, 0)
    assert {:ok, 0} = Xfp.Driver.read_pin(0, @test_pin)
  end

  test "Restart if c program crashs" do
    pid =
      :os.cmd(:"ps -ef | grep -v grep | grep 'xfp' | awk '{print $2}'")
      |> to_string
      |> String.replace(~r/\r|\n/, "")

    # kill c program
    ("kill -9 " <> pid)
    |> String.to_atom()
    |> :os.cmd()

    # sleep to allow the system to crash
    :timer.sleep(100)

    assert nil !=
             :os.cmd(:"ps -ef | grep -v grep | grep 'xfp' | awk '{print $2}'")
             |> to_string
             |> String.replace(~r/\r|\n/, "")
  end

  test "Check Xfp.Driver normal crash" do
    assert pid = Process.whereis(Xfp.Driver)
    Process.exit(pid, :normal)
    # sleep to allow the system to crash
    :timer.sleep(100)
    assert nil != Process.whereis(Xfp.Driver)
    assert pid != Process.whereis(Xfp.Driver)
  end
end
