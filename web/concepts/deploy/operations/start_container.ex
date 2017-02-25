defmodule Juggler.Deploy.Operations.StartContainer do
  alias Juggler.Docker.Operations.StartDockerContainer
  alias Juggler.Deploy.Operations.UpdateState
  alias Juggler.{Repo, Deploy}
  require Logger
  import Monad.Result, only: [success?: 1,
                              unwrap!: 1,
                              success: 1,
                              error: 1]

  def call(deploy) do
    result = StartDockerContainer.call(deploy.project_id)

    if success?(result) do
      changeset = Deploy.changeset(deploy, %{:container_id => result.value})
      case Repo.update(changeset) do
        {:ok, deploy} ->
          Logger.info " ---> New docker cont " <> deploy.container_id <> " deploy: " <> Integer.to_string(deploy.id)
          UpdateState.call(deploy, "running")
          success(deploy)
        {:error, _changeset} ->
          error_msg = "Error updating deploy " <> Integer.to_string(deploy.id) <> " with container_id"
          Logger.error error_msg
          error(error_msg)
      end
    else
      result
    end
  end

end
