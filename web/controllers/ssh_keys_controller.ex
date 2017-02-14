defmodule Juggler.SSHKeysController do
  use Juggler.Web, :controller

  alias Juggler.SSHKey
  alias Juggler.Project

  plug Juggler.Plugs.Authenticated
  plug :authorize_project

  def index(conn, %{"project_id" => project_id}) do
      project = Project |> Repo.get!(project_id) |> Repo.preload([:ssh_keys])
      render conn, "index.json", ssh_keys: project.ssh_keys
  end

  defp authorize_project(conn, _) do
    case conn.params do
      %{"project_id" => id} ->
        project = Project |> Repo.get!(id)
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
