defmodule Xfp.Application do
  @moduledoc """
  This is the entry point for the main application 
  """
  use Application

  def start(_type, _args) do
    Xfp.Supervisor.start_link()
  end
end
