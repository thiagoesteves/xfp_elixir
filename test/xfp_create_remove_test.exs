defmodule XfpCreateRemoveTest do
  use ExUnit.Case
  doctest Xfp.Sup

  test "Create Xfp" do
    assert {:ok, _} = Xfp.Sup.create_xfp 
  end

  test "Create Xfp and Remove XFP" do
    assert {:ok, _} = Xfp.Sup.create_xfp 1
    assert :ok      = Xfp.Sup.remove_xfp 1
  end
end
