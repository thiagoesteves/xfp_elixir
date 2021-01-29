defmodule XfpDynamicData do
  use ExUnit.Case
  doctest Xfp.Application

  @app_name :xfp_app

  setup do
    Application.start(@app_name)
    on_exit fn -> Application.stop(@app_name) end
    :ok
  end

  test "read state" do
    assert {:ok, _} = Xfp.Sup.create_xfp
    assert %{aux_monitoring: 255, 
             cdr_sup: 0, 
             data_code: 'DATACODE', 
             diagnostic: 255, 
             enhanced: 85, 
             identifier: 6, 
             inst: 0, 
             name: :"Xfp:0", 
             part_number: 'VENDOR PARTNUMBE',
             present: true, 
             revision: '01', 
             vendor_name: 'VENDOR NAME  XFP', 
             vendor_oui: 2097152, 
             vendor_serial: 'VENDOR SERIALNUM', 
             wavelength: 1131.5} == Xfp.get_state
  end

  test "read temperature" do
    assert {:ok, _} = Xfp.Sup.create_xfp
    assert {:ok, 64.0234375} = Xfp.get_temperature
  end

  test "read power" do
    assert {:ok, _} = Xfp.Sup.create_xfp
    assert {:ok, 7.107518348841256} = Xfp.get_rx_power
    assert {:ok, -40.0} = Xfp.get_tx_power
    assert {:ok, 0.0} = Xfp.get_tx_power_mw
    assert {:ok, 5.1375} = Xfp.get_rx_power_mw
    assert {:ok, 130.814} = Xfp.get_tx_bias
  end

  test "check pin states" do
    assert {:ok, _} = Xfp.Sup.create_xfp
    assert {:ok, 0} = Xfp.get_rx_los
    assert {:ok, 0} = Xfp.get_xfp_not_ready
    assert {:ok, 1} = Xfp.get_laser_state
    assert {:ok, 0.0} = Xfp.get_tx_power_mw
    assert {:ok, 5.1375} = Xfp.get_rx_power_mw
    assert {:ok, 130.814} = Xfp.get_tx_bias
  end

  test "check laser on/off" do
    assert {:ok, _} = Xfp.Sup.create_xfp
    assert {:ok, 0} = Xfp.set_laser_on
    assert {:ok, 1} = Xfp.get_laser_state
    assert {:ok, 0} = Xfp.set_laser_off
    assert {:ok, 0} = Xfp.get_laser_state
    assert {:ok, 0} = Xfp.set_laser_on
    assert {:ok, 1} = Xfp.get_laser_state
  end

  test "reset" do
    assert {:ok, _} = Xfp.Sup.create_xfp
    assert {:ok, 0} = Xfp.set_reset
  end

  test "change presence" do
    assert {:ok, pid} = Xfp.Sup.create_xfp
    assert %{present: true} = Xfp.get_state
    Xfp.Driver.write_pin(0, 2, 1)
    force_presence_update(pid)
    assert %{present: false} = Xfp.get_state
    Xfp.Driver.write_pin(0, 2, 0)
    force_presence_update(pid)
    assert %{present: true} = Xfp.get_state
  end

  test "invalid request" do
    assert {:ok, pid} = Xfp.Sup.create_xfp
    :ignored = GenServer.call(pid, :none)
  end

  test "read not present" do
    assert {:ok, pid} = Xfp.Sup.create_xfp
    Xfp.Driver.write_pin(0, 2, 1)
    force_presence_update(pid)
    force_presence_update(pid)
    assert {:error, :not_present} = Xfp.get_temperature
    assert {:error, :not_present} = Xfp.get_rx_los
    assert {:error, :not_present} = Xfp.get_xfp_not_ready
    assert {:error, :not_present} = Xfp.get_laser_state
    assert {:error, :not_present} = Xfp.get_tx_power_mw
    assert {:error, :not_present} = Xfp.get_rx_power_mw
    assert {:error, :not_present} = Xfp.get_tx_bias
    assert {:error, :not_present} = Xfp.get_rx_los
    assert {:error, :not_present} = Xfp.get_xfp_not_ready
    assert {:error, :not_present} = Xfp.get_laser_state
    assert {:error, :not_present} = Xfp.get_tx_power_mw
    assert {:error, :not_present} = Xfp.get_rx_power_mw
    assert {:error, :not_present} = Xfp.get_tx_bias
    assert {:error, :not_present} = Xfp.set_reset
  end

  defp force_presence_update(pid) do
      Process.send(pid, :check_presence, [])
      :timer.sleep(100)
  end
end
