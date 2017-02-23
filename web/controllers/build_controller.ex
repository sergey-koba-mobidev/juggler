defmodule Juggler.BuildController do
  use Juggler.Web, :controller

  alias Juggler.{Build, Project}
  alias Juggler.Build.Operations.StartBuild

  plug Juggler.Plugs.Authenticated
  plug Juggler.Project.Plugs.Authenticate

  def create(conn, %{"project_id" => project_id}) do
    project = Project |> Repo.get!(project_id)

    changeset = Build.changeset(%Build{}, %{
      :project_id => project_id,
      :key => Integer.to_string(DateTime.to_unix(DateTime.utc_now)),
      :state => "new",
      :commands => project.build_commands
    })

    case Repo.insert(changeset) do
      {:ok, build} ->
        StartBuild.call(build)
        conn
        |> put_flash(:info, "Build started successfully.")
        |> redirect(to: project_build_path(conn, :show, project_id, build))
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Unable to start build.")
        |> redirect(to: project_path(conn, :show, project_id))
    end
  end

  def index(conn, params = %{"project_id" => project_id}) do
    project = Project |> Repo.get!(project_id)
    {builds, kerosene} =
      from(b in Build, where: b.project_id == ^project_id)
      |> Repo.paginate(params)
    render(conn, "index.html", builds: builds, kerosene: kerosene, project: project)
  end

  def show(conn, %{"id" => id}) do
    build = Build |> Repo.get!(id) |> Repo.preload([:project])
    render(conn, "show.html", build: build)
  end
end
