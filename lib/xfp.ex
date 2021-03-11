defmodule Xfp do
  @moduledoc """
  This module contains all the individual xfp functions
  """
  use GenServer
  require Logger

  ### ==========================================================================
  ### Local Defines
  ### ==========================================================================
  @xFP_CHECK_PRESENCE_INTERVAL 1000
  @xFP_DEFAULT_INSTANCE 0

  # PIN Defines - See xfp_driver.c enumeration
  # @xFP_PIN_MOD_DESEL          0
  @xFP_PIN_TX_DIS 1
  @xFP_PIN_PRESENCE 2
  @xFP_PIN_NOT_READY 3
  @xFP_PIN_RX_LOS 4
  @xFP_PIN_RESET 5
  # @xFP_PIN_POWERDOWN          6
  # @xFP_MAX_PIN                7
  @xFP_PRESENT 0
  # @xFP_LASER_ON               0
  # @xFP_LASER_OFF              1

  # Register Defines
  # Lower Memory Map
  @xFP_REG_TEMPERATURE 96
  @xFP_REG_TX_BIAS 100
  @xFP_REG_TX_POWER 102
  @xFP_REG_RX_POWER 104
  # @xFP_REG_SELECT_PAGE        127
  # Table 01
  @xFP_REG_IDENTIFIER 128
  @xFP_REG_VENDOR_NAME 148
  @xFP_REG_CDR_SUP 164
  @xFP_REG_VENDOR_OUI 165
  @xFP_REG_PART_NUMBER 168
  @xFP_REG_REVISION 184
  @xFP_REG_WAVELENGTH 186
  @xFP_REG_VENDOR_SERIAL 196
  @xFP_REG_DATE_CODE 212
  @xFP_REG_DIAGNOSTIC 220
  @xFP_REG_ENHANCED 221
  @xFP_REG_AUX_MONITORING 222
  # Define registers size for the values bigger than 1
  @xFP_REG_TEMPERATURE_SIZE 2
  @xFP_REG_TX_BIAS_SIZE 2
  @xFP_REG_TX_POWER_SIZE 2
  @xFP_REG_RX_POWER_SIZE 2
  @xFP_REG_VENDOR_NAME_SIZE 16
  # @xFP_REG_CDR_SUP_SIZE       1
  @xFP_REG_VENDOR_OUI_SIZE 3
  @xFP_REG_PART_NUMBER_SIZE 16
  @xFP_REG_REVISION_SIZE 2
  @xFP_REG_WAVELENGTH_SIZE 2
  @xFP_REG_VENDOR_SERIAL_SIZE 16
  @xFP_REG_DATE_CODE_SIZE 8
  # Generic definition
  @xFP_REG_SIZE_BITS 16
  @xFP_REG_OUI_SIZE_BITS 24
  # Minimum Dbm power measure
  @xFP_DBM_MIN -40.0
  # Reset delay im ms
  @xFP_RESET_DELAY 100

  ### ==========================================================================
  ### Types
  ### ==========================================================================
  @type xfp_instance :: non_neg_integer()
  @type return_integer :: {:ok | :error, non_neg_integer()}
  @type return_float :: {:ok | :error, float}

  ### ==========================================================================
  ### GenServer Callbacks
  ### ==========================================================================

  def start_link([xfp_name, instance]) do
    GenServer.start_link(__MODULE__, [xfp_name, instance], name: xfp_name)
  end

  @impl true
  def init([xfp_name, instance]) do
    state = %{inst: instance, name: xfp_name, present: false}
    Logger.info("I'm Xfp #{inspect(state)}")
    # Register Gproc name
    :gproc.reg({:p, :l, {__MODULE__, instance}})
    # Start the check presence interval for the device with check_presence msg
    Process.send(self(), :check_presence, [])
    {:ok, state}
  end

  @impl true
  def handle_cast(_msg, state) do
    {:noreply, state}
  end

  @impl true
  def handle_call({:get, :state}, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:get, _}, _from, %{present: false} = state) do
    {:reply, {:error, :not_present}, state}
  end

  def handle_call({:get, operation}, _from, state) do
    res = read_priv(operation, state[:inst])
    {:reply, res, state}
  end

  def handle_call({:set, _}, _from, %{present: false} = state) do
    {:reply, {:error, :not_present}, state}
  end

  def handle_call({:set, operation}, _from, state) do
    res = write_priv(operation, state[:inst])
    {:reply, res, state}
  end

  def handle_call(_request, _from, state) do
    {:reply, :ignored, state}
  end

  @impl true
  def handle_info(:check_presence, state) do
    # update state
    new_state =
      get_presence_pin(state)
      |> update_xfp_presence(state.present, state)

    # Notify loop
    Process.send_after(self(), :check_presence, @xFP_CHECK_PRESENCE_INTERVAL)
    {:noreply, new_state}
  end

  @impl true
  def terminate(_, _) do
    :gproc.goodbye()
  end

  ### ==========================================================================
  ### Public Xfp functions
  ### ==========================================================================
  @spec get_state(xfp_instance) :: {:ok, %{}}
  def get_state(instance \\ @xFP_DEFAULT_INSTANCE) when is_number(instance) do
    gproc_call(instance, {:get, :state})
  end

  @spec get_temperature(xfp_instance) :: return_float
  def get_temperature(instance \\ @xFP_DEFAULT_INSTANCE) when is_number(instance) do
    gproc_call(instance, {:get, :temperature})
  end

  @spec get_tx_bias(xfp_instance) :: return_float
  def get_tx_bias(instance \\ @xFP_DEFAULT_INSTANCE) when is_number(instance) do
    gproc_call(instance, {:get, :tx_bias})
  end

  @spec get_tx_power_mw(xfp_instance) :: return_float
  def get_tx_power_mw(instance \\ @xFP_DEFAULT_INSTANCE) when is_number(instance) do
    gproc_call(instance, {:get, :tx_power_mw})
  end

  @spec get_tx_power(xfp_instance) :: return_float
  def get_tx_power(instance \\ @xFP_DEFAULT_INSTANCE) when is_number(instance) do
    gproc_call(instance, {:get, :tx_power_dbm})
  end

  @spec get_rx_power_mw(xfp_instance) :: return_float
  def get_rx_power_mw(instance \\ @xFP_DEFAULT_INSTANCE) when is_number(instance) do
    gproc_call(instance, {:get, :rx_power_mw})
  end

  @spec get_rx_power(xfp_instance) :: return_float
  def get_rx_power(instance \\ @xFP_DEFAULT_INSTANCE) when is_number(instance) do
    gproc_call(instance, {:get, :rx_power_dbm})
  end

  @spec get_rx_los(xfp_instance) :: return_integer
  def get_rx_los(instance \\ @xFP_DEFAULT_INSTANCE) when is_number(instance) do
    gproc_call(instance, {:get, :rx_los})
  end

  @spec get_laser_state(xfp_instance) :: return_integer
  def get_laser_state(instance \\ @xFP_DEFAULT_INSTANCE) when is_number(instance) do
    gproc_call(instance, {:get, :laser_state})
  end

  @spec get_xfp_not_ready(xfp_instance) :: return_integer
  def get_xfp_not_ready(instance \\ @xFP_DEFAULT_INSTANCE) when is_number(instance) do
    gproc_call(instance, {:get, :xfp_not_ready})
  end

  @spec set_laser_on(xfp_instance) :: return_integer
  def set_laser_on(instance \\ @xFP_DEFAULT_INSTANCE) when is_number(instance) do
    gproc_call(instance, {:set, :laser_on})
  end

  @spec set_laser_off(xfp_instance) :: return_integer
  def set_laser_off(instance \\ @xFP_DEFAULT_INSTANCE) when is_number(instance) do
    gproc_call(instance, {:set, :laser_off})
  end

  @spec set_reset(xfp_instance) :: return_integer
  def set_reset(instance \\ @xFP_DEFAULT_INSTANCE) when is_number(instance) do
    gproc_call(instance, {:set, :reset})
  end

  ### ==========================================================================
  ### Private functions
  ### ==========================================================================

  # Get the current presence state of the device
  defp get_presence_pin(state) do
    {:ok, presence} = Xfp.Driver.read_pin(state[:inst], @xFP_PIN_PRESENCE)
    pin_presence_analyse(presence)
  end

  # This function translates io state to true/false
  defp pin_presence_analyse(@xFP_PRESENT) do
    true
  end

  defp pin_presence_analyse(_) do
    false
  end

  # Update xfp data if needed
  # Update the xfp data from not present to present
  defp update_xfp_presence(true, false, state) do
    upload_xfp_static_information(state)
  end

  # Update the xfp data from present to not present
  defp update_xfp_presence(false, true, state) do
    %{inst: state[:inst], name: state[:name], present: false}
  end

  # No change of state
  defp update_xfp_presence(_, _, state) do
    state
  end

  # Get the current state of the device
  defp upload_xfp_static_information(state) do
    # 1 byte information
    {:ok, id} = Xfp.Driver.read_register(state[:inst], @xFP_REG_IDENTIFIER)
    {:ok, diagnostic} = Xfp.Driver.read_register(state[:inst], @xFP_REG_DIAGNOSTIC)
    {:ok, enhanced} = Xfp.Driver.read_register(state[:inst], @xFP_REG_ENHANCED)
    {:ok, aux_mon} = Xfp.Driver.read_register(state[:inst], @xFP_REG_AUX_MONITORING)
    {:ok, cdr_sup} = Xfp.Driver.read_register(state[:inst], @xFP_REG_CDR_SUP)
    # >1 byte information
    vendor_name =
      read_xfp_string(
        state[:inst],
        @xFP_REG_VENDOR_NAME,
        @xFP_REG_VENDOR_NAME_SIZE
      )

    vendor_part =
      read_xfp_string(
        state[:inst],
        @xFP_REG_PART_NUMBER,
        @xFP_REG_PART_NUMBER_SIZE
      )

    vendor_serial =
      read_xfp_string(
        state[:inst],
        @xFP_REG_VENDOR_SERIAL,
        @xFP_REG_VENDOR_SERIAL_SIZE
      )

    vendor_datecode =
      read_xfp_string(
        state[:inst],
        @xFP_REG_DATE_CODE,
        @xFP_REG_DATE_CODE_SIZE
      )

    revision =
      read_xfp_string(
        state[:inst],
        @xFP_REG_REVISION,
        @xFP_REG_REVISION_SIZE
      )

    # For Vendor OUI, we capture the list and convert
    vendor_oui =
      read_xfp_string(
        state[:inst],
        @xFP_REG_VENDOR_OUI,
        @xFP_REG_VENDOR_OUI_SIZE
      )
      |> convert_list_to(:oui)

    # For Wavelength, we capture the list and convert
    wavelength =
      read_xfp_string(
        state[:inst],
        @xFP_REG_WAVELENGTH,
        @xFP_REG_WAVELENGTH_SIZE
      )
      |> convert_list_to(:wavelenth)

    # Update all information but instance
    state
    |> Map.put(:identifier, id)
    |> Map.put(:present, true)
    |> Map.put(:vendor_name, vendor_name)
    |> Map.put(:cdr_sup, cdr_sup)
    |> Map.put(:vendor_oui, vendor_oui)
    |> Map.put(:part_number, vendor_part)
    |> Map.put(:revision, revision)
    |> Map.put(:wavelength, wavelength)
    |> Map.put(:vendor_serial, vendor_serial)
    |> Map.put(:data_code, vendor_datecode)
    |> Map.put(:diagnostic, diagnostic)
    |> Map.put(:enhanced, enhanced)
    |> Map.put(:aux_monitoring, aux_mon)
  end

  defp read_priv(:temperature, instance) do
    temp =
      read_xfp_string(instance, @xFP_REG_TEMPERATURE, @xFP_REG_TEMPERATURE_SIZE)
      |> convert_list_to(:temperature)

    {:ok, temp}
  end

  defp read_priv(:tx_bias, instance) do
    tx_bias =
      read_xfp_string(instance, @xFP_REG_TX_BIAS, @xFP_REG_TX_BIAS_SIZE)
      |> convert_list_to(:tx_bias)

    {:ok, tx_bias}
  end

  defp read_priv(:tx_power_mw, instance) do
    tx_power =
      read_xfp_string(instance, @xFP_REG_TX_POWER, @xFP_REG_TX_POWER_SIZE)
      |> convert_list_to(:power_mw)

    {:ok, tx_power}
  end

  defp read_priv(:tx_power_dbm, instance) do
    tx_power =
      read_xfp_string(instance, @xFP_REG_TX_POWER, @xFP_REG_TX_POWER_SIZE)
      |> convert_list_to(:power_dbm)

    {:ok, tx_power}
  end

  defp read_priv(:rx_power_mw, instance) do
    rx_power =
      read_xfp_string(instance, @xFP_REG_RX_POWER, @xFP_REG_RX_POWER_SIZE)
      |> convert_list_to(:power_mw)

    {:ok, rx_power}
  end

  defp read_priv(:rx_power_dbm, instance) do
    rx_power =
      read_xfp_string(instance, @xFP_REG_RX_POWER, @xFP_REG_RX_POWER_SIZE)
      |> convert_list_to(:power_dbm)

    {:ok, rx_power}
  end

  defp read_priv(:rx_los, instance) do
    Xfp.Driver.read_pin(instance, @xFP_PIN_RX_LOS)
  end

  defp read_priv(:laser_state, instance) do
    {:ok, tx_dis} = Xfp.Driver.read_pin(instance, @xFP_PIN_TX_DIS)
    {:ok, invert_data(tx_dis)}
  end

  defp read_priv(:xfp_not_ready, instance) do
    Xfp.Driver.read_pin(instance, @xFP_PIN_NOT_READY)
  end

  defp write_priv(:laser_on, instance) do
    Xfp.Driver.write_pin(instance, @xFP_PIN_TX_DIS, 0)
  end

  defp write_priv(:laser_off, instance) do
    Xfp.Driver.write_pin(instance, @xFP_PIN_TX_DIS, 1)
  end

  defp write_priv(:reset, instance) do
    Xfp.Driver.write_pin(instance, @xFP_PIN_RESET, 0)
    :timer.sleep(@xFP_RESET_DELAY)
    Xfp.Driver.write_pin(instance, @xFP_PIN_RESET, 1)
  end

  defp read_xfp_string(instance, register, size) do
    Enum.map(
      0..(size - 1),
      fn x ->
        {:ok, value} = Xfp.Driver.read_register(instance, register + x)
        value
      end
    )
  end

  # Convert a List to a unsigned number
  defp list_to_unumber(list, bits) do
    <<num::little-unsigned-integer-size(bits)>> = :erlang.list_to_binary(list)
    num
  end

  # Convert a List to a signed number
  defp list_to_snumber(list, bits) do
    <<num::little-signed-integer-size(bits)>> = :erlang.list_to_binary(list)
    num
  end

  # in celsius
  defp convert_list_to(list, :temperature) do
    list_to_snumber(list, @xFP_REG_SIZE_BITS) / 256
  end

  # in mA
  defp convert_list_to(list, :tx_bias) do
    list_to_unumber(list, @xFP_REG_SIZE_BITS) / 500
  end

  # in mw
  defp convert_list_to(list, :power_mw) do
    list_to_unumber(list, @xFP_REG_SIZE_BITS) / 10000
  end

  # in Dbm 
  defp convert_list_to(list, :power_dbm) do
    case convert_list_to(list, :power_mw) do
      x when x > 0 -> 10 * :math.log10(x)
      _ -> @xFP_DBM_MIN
    end
  end

  # in nm
  defp convert_list_to(list, :wavelenth) do
    list_to_unumber(list, @xFP_REG_SIZE_BITS) / 20
  end

  # generic number
  defp convert_list_to(list, :oui) do
    list_to_unumber(list, @xFP_REG_OUI_SIZE_BITS)
  end

  defp invert_data(0), do: 1
  defp invert_data(1), do: 0

  # Send a gen_server:call message if the PID is found
  defp gproc_call(inst, msg) do
    key = {__MODULE__, inst}

    case :gproc.lookup_pids({:p, :l, key}) do
      [pid] -> GenServer.call(pid, msg)
      _ -> {:error, :invalid_xfp}
    end
  end
end
