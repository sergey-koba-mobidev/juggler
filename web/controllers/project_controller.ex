defmodule Juggler.ProjectController do
  use Juggler.Web, :controller

  alias Juggler.Project
  alias Juggler.Build
  alias Juggler.Server

  plug Juggler.Plugs.Authenticated
  plug :authorize_project

  def index(conn, params) do
    user_id = current_user(conn).id
    {projects, kerosene} =
      from(p in Project, where: p.user_id == ^user_id)
      |> Repo.paginate(params)
    render(conn, "index.html", projects: projects, kerosene: kerosene)
  end

  def new(conn, _params) do
    changeset = Project.changeset(%Project{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"project" => project_params}) do
    changeset = Project.changeset(%Project{}, Map.merge(project_params, %{"user_id" => current_user(conn).id}))

    case Repo.insert(changeset) do
      {:ok, _project} ->
        conn
        |> put_flash(:info, "Project created successfully.")
        |> redirect(to: project_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    project = Project |> Repo.get!(id)
    builds = from(b in Build, where: b.project_id == ^id, limit: 5) |> Repo.all
    servers = from(s in Server, where: s.project_id == ^id) |> Repo.all
    build_changeset = Build.changeset(%Build{})
    render(conn, "show.html", project: project, build_changeset: build_changeset, builds: builds, servers: servers)
  end

  def edit(conn, %{"id" => id}) do
    project = Repo.get!(Project, id)
    changeset = Project.changeset(project)
    render(conn, "edit.html", project: project, changeset: changeset)
  end

  def update(conn, %{"id" => id, "project" => project_params}) do
    project = Repo.get!(Project, id)
    changeset = Project.changeset(project, project_params)

    case Repo.update(changeset) do
      {:ok, project} ->
        conn
        |> put_flash(:info, "Project updated successfully.")
        |> redirect(to: project_path(conn, :show, project))
      {:error, changeset} ->
        render(conn, "edit.html", project: project, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    project = Repo.get!(Project, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(project)

    conn
    |> put_flash(:info, "Project was deleted successfully.")
    |> redirect(to: project_path(conn, :index))
  end

  defp authorize_project(conn, _) do
    case conn.params do
      %{"id" => id} ->
        project = Repo.get!(Project, id)
        if project.user_id == current_user(conn).id do
          conn
        else
          conn |> put_flash(:info, "You can't access that page") |> redirect(to: project_path(conn, :index)) |> halt
        end
      _ ->
        conn
    end
  end
end
