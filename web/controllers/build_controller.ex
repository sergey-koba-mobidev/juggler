defmodule Juggler.BuildController do
  use Juggler.Web, :controller

  alias Juggler.Build
  alias Juggler.Project

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
        conn
        |> put_flash(:info, "Build started successfully.")
        |> start_build(build.id)
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

  def start_build(conn, build_id) do
    Juggler.BuildServer.new_build(build_id)
    conn
  end
end
