defmodule Juggler.ProjectController do
  use Juggler.Web, :controller

  alias Juggler.{Project, ProjectUser, Build, Server, Integration, Deploy}
  alias Juggler.Project.Operations.CreateProject
  alias Juggler.Role.Operations.CheckProjectPermission

  import Juggler.Role.Helpers

  plug Juggler.Plugs.Authenticated
  plug :authorize_project

  def index(conn, params) do
    user_id = current_user(conn).id
    {projects, kerosene} =
      from(u in ProjectUser,
        where: u.user_id == ^user_id,
        join: p in Project, on: p.id == u.project_id,
        select: p
      ) |> Repo.paginate(params)
    render(conn, "index.html", projects: projects, kerosene: kerosene)
  end

  def new(conn, _params) do
    changeset = Project.changeset(%Project{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"project" => project_params}) do
    result = CreateProject.call(Map.merge(project_params, %{"user_id" => current_user(conn).id}))

    if success?(result) do
      conn
      |> put_flash(:info, "Project created successfully.")
      |> redirect(to: project_path(conn, :show, result.value))
    else
      render(conn, "new.html", changeset: result.error)
    end
  end

  def show(conn, %{"id" => id}) do
    project = Project |> Repo.get!(id)
    builds = from(b in Build, where: b.project_id == ^id, limit: 5) |> Repo.all
    deploys = from(d in Deploy, where: d.project_id == ^id, limit: 5) |> Repo.all
    servers = from(s in Server, where: s.project_id == ^id) |> Repo.all
    build_changeset = Build.changeset(%Build{})
    render(conn, "show.html", project: project, build_changeset: build_changeset, builds: builds, servers: servers, deploys: deploys)
  end

  def edit(conn, %{"id" => id}) do
    project = Repo.get!(Project, id)
    changeset = Project.changeset(project)
    integrations = from(i in Integration, where: [project_id: ^id, state: "integrated"] ) |> Repo.all
    render(conn, "edit.html", project: project, changeset: changeset, integrations: integrations)
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

    Verk.remove_queue(String.to_atom("project_" <> id))
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
        if CheckProjectPermission.call(project, current_user(conn), controller_to_string(conn.private.phoenix_controller), Atom.to_string(conn.private.phoenix_action)) do
          conn
        else
          conn |> put_flash(:info, "You can't access that page") |> redirect(to: project_path(conn, :index)) |> halt
        end
      _ ->
        conn
    end
  end
end
