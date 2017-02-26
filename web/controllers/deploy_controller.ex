defmodule Juggler.DeployController do
  use Juggler.Web, :controller

  alias Juggler.{Build, Project, Deploy, Server}
  alias Juggler.Deploy.Operations.{StartDeploy, RestartDeploy}

  plug Juggler.Plugs.Authenticated
  plug Juggler.Project.Plugs.Authenticate

  def create(conn, %{"project_id" => project_id, "deploy" => %{"build_id" => build_id, "server_id" => server_id}}) do
    server = Server |> Repo.get!(server_id)
    build  = Build  |> Repo.get!(build_id)

    changeset = Deploy.changeset(%Deploy{}, %{
      :user_id => current_user(conn).id,
      :build_id => build_id,
      :server_id => server_id,
      :project_id => project_id,
      :key => build.key,
      :state => "new",
      :commands => server.deploy_commands
    })

    case Repo.insert(changeset) do
      {:ok, deploy} ->
        StartDeploy.call(deploy)
        conn
        |> put_flash(:info, "Deploy started successfully.")
        |> redirect(to: project_deploy_path(conn, :show, project_id, deploy))
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Unable to start deploy.")
        |> redirect(to: project_path(conn, :show, project_id))
    end
  end

  def index(conn, params = %{"project_id" => project_id}) do
    project = Project |> Repo.get!(project_id)
    {deploys, kerosene} =
      from(d in Deploy, where: d.project_id == ^project_id)
      |> Repo.paginate(params)
    render(conn, "index.html", deploys: deploys, kerosene: kerosene, project: project)
  end

  def show(conn, %{"id" => id}) do
    deploy = Deploy |> Repo.get!(id) |> Repo.preload([:project, :server, :build, :user])
    render(conn, "show.html", deploy: deploy)
  end

  def restart(conn, %{"deploy_id" => id}) do
    deploy = Deploy |> Repo.get!(id)
    RestartDeploy.call(deploy)
    conn
    |> put_flash(:info, "Build restarted successfully.")
    |> redirect(to: project_deploy_path(conn, :show, deploy.project_id, deploy))
  end
end
