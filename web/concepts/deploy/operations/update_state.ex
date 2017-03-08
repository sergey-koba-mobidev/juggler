defmodule Juggler.Deploy.Operations.UpdateState do
  alias Juggler.{Repo, Deploy}
  require Logger
  import Monad.Result, only: [success?: 1,
                              unwrap!: 1,
                              success: 1,
                              error: 1]

  def call(deploy, new_state) do
    changeset = Deploy.changeset(deploy, %{:state => new_state})

    case Repo.update(changeset) do
      {:ok, deploy} ->
        Logger.info " ---> New deploy " <> Integer.to_string(deploy.id) <> " state: " <> new_state
        payload = %{id: deploy.id, state: deploy.state, html: Phoenix.HTML.safe_to_string(Juggler.DeployView.icon(deploy))}
        Juggler.Endpoint.broadcast("deploy:" <> Integer.to_string(deploy.id), "new_deploy_state", payload)
        Juggler.Endpoint.broadcast("project:" <> Integer.to_string(deploy.project_id), "new_deploy_state", payload)
        success(deploy)
      {:error, _changeset} ->
        Logger.error "Error updating deploy " <> Integer.to_string(deploy.id) <> " state to " <> new_state
        error("Error updating deploy " <> Integer.to_string(deploy.id) <> " state to " <> new_state)
    end
  end

end
