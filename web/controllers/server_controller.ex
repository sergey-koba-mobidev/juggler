defmodule Juggler.ServerController do
  use Juggler.Web, :controller
  alias Juggler.Repo
  alias Juggler.Project
  alias Juggler.Server

  plug Juggler.Plugs.Authenticated
  plug Juggler.Project.Plugs.Authenticate

  def show(conn, %{"project_id" => project_id, "id" => id}) do
    project = Project |> Repo.get!(project_id)
    server = Server |> Repo.get!(id)
    render(conn, "show.html", server: server, project: project)
  end

  def new(conn, %{"project_id" => project_id}) do
    project = Project |> Repo.get!(project_id)
    changeset = Server.changeset(%Server{})
    render(conn, "new.html", changeset: changeset, project: project)
  end

  def create(conn, %{"project_id" => project_id, "server" => server_params}) do
    project = Project |> Repo.get!(project_id)
    changeset = Server.changeset(%Server{}, Map.merge(server_params, %{"project_id" => project_id}))

    case Repo.insert(changeset) do
      {:ok, _server} ->
        conn
        |> put_flash(:info, "Server created successfully.")
        |> redirect(to: project_path(conn, :show, project))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, project: project)
    end
  end

  def edit(conn, %{"project_id" => project_id, "id" => id}) do
    project = Project |> Repo.get!(project_id)
    server = Repo.get!(Server, id)
    changeset = Server.changeset(server)
    render(conn, "edit.html", server: server, project: project, changeset: changeset)
  end

  def update(conn, %{"project_id" => project_id, "id" => id, "server" => server_params}) do
    project = Project |> Repo.get!(project_id)
    server = Repo.get!(Server, id)
    changeset = Server.changeset(server, server_params)

    case Repo.update(changeset) do
      {:ok, server} ->
        conn
        |> put_flash(:info, "Server updated successfully.")
        |> redirect(to: project_path(conn, :show, project))
      {:error, changeset} ->
        render(conn, "edit.html", project: project, changeset: changeset)
    end
  end

  def delete(conn, %{"project_id" => project_id, "id" => id}) do
    project = Project |> Repo.get!(project_id)
    server = Repo.get!(Server, id)

    Repo.delete!(server)

    conn
    |> put_flash(:info, "Server was deleted successfully.")
    |> redirect(to: project_path(conn, :show, project))
  end
end
