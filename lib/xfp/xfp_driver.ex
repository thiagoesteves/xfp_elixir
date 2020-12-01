defmodule Xfp.Driver do
  @moduledoc """
    This module contains the port that will give access to the driver
    """
  use GenServer
  require Logger
  
  ###==========================================================================
  ### Local Defines
  ###==========================================================================
  @timeout 1000

  ###==========================================================================
  ### Types
  ###==========================================================================
  @type xfp_instance :: non_neg_integer() 
  
  ###==========================================================================
  ### GenServer Callbacks
  ###==========================================================================
  
  def start_link([]) do
    GenServer.start_link(__MODULE__, [], [name: __MODULE__])
  end
  
  @impl true
  def init([]) do
    # Allow terminate being called before crash
    Process.flag(:trap_exit, true)
    # Open port and initialise driver to communicate with external program
    port =
      open_port()
      |> init_port()
    Logger.info "Xfp Driver is sending/receiving at port: #{inspect(port)}"
    {:ok, %{port: port, exit_status: nil} }
  end

  @impl true
  def handle_call(msg, _from, %{exit_status: nil} = state) do
    res = talk_to_port(state[:port], msg)
    {:reply, res, state}
  end

  def handle_call(_, _from, %{exit_status: status} = state) when status !== nil do
    {:reply, {:error, :port_disconnected}, state}
  end

  @impl true
  def handle_info({port, {:exit_status, reason}}, %{port: port} = state) do
    Logger.error "#{__MODULE__} handled EXIT message from
                                port: #{inspect port} reason #{inspect reason}"
    {:noreply, state |> Map.put(:exit_status, reason) }
  end

  def handle_info({:EXIT, from, reason}, state) do
    Logger.error "#{__MODULE__} handled EXIT message 
                                from: #{inspect from} reason:#{inspect reason}"
    {:stop, reason, state}
  end

  @impl true
  def terminate(:normal, %{port: port, exit_status: nil}) do
    Logger.info "#{__MODULE__} is terminating port: #{inspect port}"
    cleanup(port)
      |> Port.close()
    :normal
  end

  def terminate(reason, %{port: port}) do
    Logger.info "#{__MODULE__} is terminating
                               port: #{inspect port} reason #{inspect reason}"
    :normal
  end

  ###==========================================================================
  ### Public Xfp functions
  ###==========================================================================
  @spec read_register(xfp_instance, integer) :: { :ok | :error , integer() }
  def read_register(instance, register) do
    GenServer.call(__MODULE__, {:read_register, instance, register})
  end

  @spec write_register(xfp_instance, integer, integer) :: { :ok | :error , integer() }
  def write_register(instance, register, value) do
    GenServer.call(__MODULE__, {:write_register, instance, register, value})
  end
  
  @spec read_pin(xfp_instance, non_neg_integer) :: { :ok | :error , integer() }
  def read_pin(instance, pin) do
    GenServer.call(__MODULE__, {:read_pin, instance, pin})
  end

  @spec write_pin(xfp_instance, non_neg_integer, non_neg_integer) :: { :ok | :error , integer() }
  def write_pin(instance, pin, value) do
    GenServer.call(__MODULE__, {:write_pin, instance, pin, value})
  end

  ###==========================================================================
  ### Private functions
  ###==========================================================================

  defp open_port do
    executable = :code.priv_dir(:xfp_app) ++ '/c/xfp'
    Port.open({:spawn, executable},[{:packet, 2}, :binary, :exit_status])
  end

  defp talk_to_port(port,msg) do
    Port.command(port, :erlang.term_to_binary(msg))
    receive do
      {^port, {:data, d = <<131, 104, 2, _::binary>>}} ->
        :erlang.binary_to_term(d)
    after
      @timeout -> {:error, :timedout}
    end
  end

  defp init_port(port) do
    {:ok, _} = talk_to_port(port , {:open_xfp_driver})
    port
  end

  defp cleanup(port) do
    talk_to_port(port , {:close_xfp_driver})
    port
  end
end