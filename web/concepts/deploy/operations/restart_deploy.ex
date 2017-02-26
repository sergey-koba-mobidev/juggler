defmodule Juggler.Deploy.Operations.RestartDeploy do
  alias Juggler.Deploy.Operations.UpdateState
  alias Juggler.{Repo, DeployOutput, Deploy}
  import Ecto.Query

  def call(deploy) do
    from(d in DeployOutput, where: d.deploy_id == ^deploy.id) |> Repo.delete_all
    deploy
    |> Ecto.Changeset.change(%{inserted_at: Ecto.DateTime.utc})
    |> Repo.update
    UpdateState.call(deploy, "new")
    Verk.enqueue(%Verk.Job{queue: String.to_atom("project_" <> Integer.to_string(deploy.project_id)), class: "ExecDeployJob", args: [deploy.id], max_retry_count: 0})
  end
end
