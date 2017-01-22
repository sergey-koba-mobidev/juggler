defmodule Juggler.BuildController do
  require IEx
  use Juggler.Web, :controller

  alias Juggler.Build

  def create(conn, %{"project_id" => project_id}) do
    changeset = Build.changeset(%Build{}, %{:project_id => project_id, :key => Integer.to_string(DateTime.to_unix(DateTime.utc_now))})
    IEx.pry
    case Repo.insert(changeset) do
      {:ok, _build} ->
        conn
        |> put_flash(:info, "Build started successfully.")
        |> redirect(to: project_build_path(conn, :show, project_id, _build))
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Unable to start build.")
        |> redirect(to: project_path(conn, :show, project_id))
    end
  end

  def show(conn, %{"id" => id}) do
    build = Repo.get!(Build, id)
    render(conn, "show.html", build: build)
  end
end
