defmodule Juggler.BuildServer do
  use GenServer
  require Logger
  import Juggler.BuildOperations

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def new_build(build_id) do
    GenServer.cast(:build_server, {:new_build, build_id})
  end

  def handle_cast({:new_build, build_id}, state) do
    Logger.info " ---> Started build " <> Integer.to_string(build_id)
    spawn fn -> exec_build(build_id) end
    {:noreply, [build_id | state]}
  end
end
