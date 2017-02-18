defmodule Juggler.ServerController do
  use Juggler.Web, :controller
  alias Juggler.Repo
  alias Juggler.Project
  alias Juggler.Server

  plug Juggler.Plugs.Authenticated
  plug Juggler.Project.Plugs.Authenticate

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
end
