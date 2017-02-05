defmodule Juggler.BuildController do
  use Juggler.Web, :controller

  alias Juggler.Build
  alias Juggler.Project

  plug Juggler.Plugs.Authenticated
  plug :authorize_build

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

  def show(conn, %{"id" => id}) do
    build = Build |> Repo.get!(id) |> Repo.preload([:project])
    render(conn, "show.html", build: build)
  end

  def start_build(conn, build_id) do
    Juggler.BuildServer.new_build(build_id)
    conn
  end

  defp authorize_build(conn, _) do
    case conn.params do
      %{"id" => id} ->
        build = Build |> Repo.get!(id) |> Repo.preload([:project])
        if build.project.user_id == current_user(conn).id do
          conn
        else
          conn |> put_flash(:info, "You can't access that page") |> redirect(to: project_path(conn, :index)) |> halt
        end
      _ ->
        conn
    end
  end
end
