defmodule Juggler.Build.Operations.StartBuild do
  alias Juggler.{Repo, Project}

  def call(build) do
    project = Project |> Repo.get!(build.project_id)
    Verk.enqueue(%Verk.Job{queue: String.to_atom("project_" <> Integer.to_string(build.project_id)), class: "ExecBuildJob", args: [build.id], max_retry_count: 0})
    Juggler.Endpoint.broadcast("project:" <> Integer.to_string(build.project_id), "new_build", %{
      build: build,
      html: Phoenix.HTML.escape_javascript(Phoenix.View.render_to_string(Juggler.BuildView, "list_item.html", build: build, project: project))
    })
  end
end
