defmodule Juggler.Build.Operations.RestartBuild do
  alias Juggler.Build.Operations.UpdateState
  alias Juggler.{Repo, BuildOutput, Build, Project}
  import Ecto.Query

  def call(build) do
    project = Project |> Repo.get!(build.project_id)
    from(b in BuildOutput, where: b.build_id == ^build.id) |> Repo.delete_all
    build
    |> Ecto.Changeset.change(%{inserted_at: Ecto.DateTime.utc})
    |> Repo.update
    UpdateState.call(build, "new")
    Verk.enqueue(%Verk.Job{queue: String.to_atom("user_" <> Integer.to_string(project.user_id)), class: "ExecBuildJob", args: [build.id], max_retry_count: 0})
  end
end
