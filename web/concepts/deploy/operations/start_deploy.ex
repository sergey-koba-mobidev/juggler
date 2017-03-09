defmodule Juggler.Deploy.Operations.StartDeploy do
  alias Juggler.{Repo, Project}

  def call(deploy) do
    project = Project |> Repo.get!(deploy.project_id)
    Verk.enqueue(%Verk.Job{queue: String.to_atom("user_" <> Integer.to_string(project.user_id)), class: "ExecDeployJob", args: [deploy.id], max_retry_count: 0})
    Juggler.Endpoint.broadcast("project:" <> Integer.to_string(deploy.project_id), "new_deploy", %{
      deploy_id: deploy.id,
      html: Phoenix.View.render_to_string(Juggler.DeployView, "list_item.html", deploy: deploy, project: project)
    })
  end
end
