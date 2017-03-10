defmodule Juggler.Deploy.Operations.RestartDeploy do
  alias Juggler.Deploy.Operations.UpdateState
  alias Juggler.{Repo, DeployOutput, Deploy, Project}
  import Ecto.Query

  def call(deploy) do
    project = Project |> Repo.get!(deploy.project_id)
    from(d in DeployOutput, where: d.deploy_id == ^deploy.id) |> Repo.delete_all
    deploy
    |> Ecto.Changeset.change(%{inserted_at: Ecto.DateTime.utc})
    |> Repo.update
    UpdateState.call(deploy, "new")
    Verk.enqueue(%Verk.Job{queue: String.to_atom("user_" <> Integer.to_string(project.user_id)), class: "ExecDeployJob", args: [deploy.id], max_retry_count: 0})
  end
end
