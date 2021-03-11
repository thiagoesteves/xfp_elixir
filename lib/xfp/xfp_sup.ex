defmodule Xfp.Sup do
  @moduledoc """
  This supervisor will handle all the individuals XFP that will be
  created dinamically by the user
  """
  use Supervisor

  def start_link([]) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init([]) do
    children = []
    Supervisor.init(children, strategy: :one_for_one)
  end

  ### ==========================================================================
  ### Types
  ### ==========================================================================
  @type xfp_instance :: non_neg_integer()

  ### ==========================================================================
  ### Local Defines
  ### ==========================================================================
  @xFP_DEFAULT_INSTANCE 0

  ### ==========================================================================
  ### Public API functions
  ### ==========================================================================
  @spec create_xfp(xfp_instance) :: {:ok, pid()}
  def create_xfp(instance \\ @xFP_DEFAULT_INSTANCE) when is_integer(instance) do
    xfp_id = compose_xfp_name(instance)

    spec = %{
      id: xfp_id,
      start: {Xfp, :start_link, [[xfp_id, 0]]},
      restart: :transient,
      type: :worker
    }

    Supervisor.start_child(__MODULE__, spec)
  end

  @spec remove_xfp(xfp_instance) :: :ok
  def remove_xfp(instance \\ @xFP_DEFAULT_INSTANCE) when is_integer(instance) do
    xfp_id = compose_xfp_name(instance)
    Supervisor.terminate_child(__MODULE__, xfp_id)
    Supervisor.delete_child(__MODULE__, xfp_id)
  end

  ### ==========================================================================
  ### Private functions
  ### ==========================================================================
  defp compose_xfp_name(inst) do
    ("Xfp:" <> to_string(inst)) |> String.to_atom()
  end
end
