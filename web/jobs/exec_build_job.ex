defmodule ExecBuildJob do
  require Logger
  import Juggler.BuildOperations

  def perform(build_id) do
    Logger.info " ---> Started build " <> Integer.to_string(build_id)
    exec_build(build_id)
    {:ok}
  end
end
