defmodule Juggler.Build.Operations.RestartBuild do
  alias Juggler.Build.Operations.UpdateState
  alias Juggler.{Repo, BuildOutput, Build}
  import Ecto.Query

  def call(build) do
    from(b in BuildOutput, where: b.build_id == ^build.id) |> Repo.delete_all
    build
    |> Ecto.Changeset.change(%{inserted_at: Ecto.DateTime.utc})
    |> Repo.update
    UpdateState.call(build, "new")
    Verk.enqueue(%Verk.Job{queue: String.to_atom("project_" <> Integer.to_string(build.project_id)), class: "ExecBuildJob", args: [build.id], max_retry_count: 0})
  end
end
