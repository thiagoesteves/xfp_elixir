defmodule TestUtil do
  
  @sleep_to_check_state 1 # in ms

  def wait_xfp_to_be_inserted(_, timeout) when timeout <= 0 do
    :error
  end

  def wait_xfp_to_be_inserted(instance, timeout) do
    case xfp_state(instance) do
      %{present: true} -> :ok
      _ -> :timer.sleep(@sleep_to_check_state)
           wait_xfp_to_be_inserted(instance, timeout - 1)
    end
  end

  defp xfp_state(instance) do
    "Xfp:" <> to_string(instance) 
      |> String.to_atom
      |> Process.whereis
      |> :sys.get_state
  end
end
