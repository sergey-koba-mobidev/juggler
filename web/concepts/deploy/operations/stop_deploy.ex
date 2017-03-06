defmodule Juggler.Deploy.Operations.StopDeploy do
  alias Juggler.Deploy.Operations.UpdateState
  alias Juggler.Docker.Operations.RemoveDockerContainer
  require Logger

  def call(deploy) do
    RemoveDockerContainer.call(deploy.container_id)
    UpdateState.call(deploy, "stopped")
  end
end
