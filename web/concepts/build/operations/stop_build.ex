defmodule Juggler.Build.Operations.StopBuild do
  alias Juggler.Build.Operations.UpdateState
  alias Juggler.Docker.Operations.RemoveDockerContainer
  require Logger

  def call(build) do
    RemoveDockerContainer.call(build.container_id)
    UpdateState.call(build, "stopped")
  end
end
