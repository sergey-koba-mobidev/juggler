defmodule ExecBuildJob do
  require Logger
  alias Juggler.Build.Operations.ExecBuild

  def perform(build_id) do
    Logger.info " ---> Started build " <> Integer.to_string(build_id)
    ExecBuild.call(build_id)
    {:ok}
  end
end
