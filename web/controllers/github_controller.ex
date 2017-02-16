defmodule Juggler.GithubController do
  use Juggler.Web, :controller
  import Juggler.GitHubOperations
  alias Juggler.Integration
  require Logger

  plug Juggler.Plugs.Authenticated
  plug Juggler.Project.Plugs.Authenticate

  def setup(conn, %{"project_id" => project_id}) do
    callback_url = "http://c9a94cfc.ngrok.io" <> project_github_path(conn, :callback, project_id)
    #callback_url = project_github_url(conn, :callback, project_id)
    redirect(conn, external: get_authorize_url(callback_url))
  end

  def callback(conn, %{"project_id" => project_id, "code" => code}) do
    # TODO: refactor to monad
    callback_url = "http://c9a94cfc.ngrok.io" <> project_github_path(conn, :callback, project_id)
    #callback_url = project_github_url(conn, :callback, project_id)

    access_token = get_access_token(callback_url, code)

    changeset = Integration.changeset(%Integration{}, %{
      :project_id => project_id,
      :key => "github",
      :data => %{access_token: access_token}
    })

    case Repo.insert(changeset) do
      {:ok, build} ->
        conn
        |> put_flash(:info, "Integrated GitHub!")
        |> redirect(to: project_path(conn, :select_project, project_id))
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Unable to integrate GitHub.")
        |> redirect(to: project_path(conn, :edit, project_id))
    end
  end

  def select_project(conn, %{"project_id" => project_id}) do
    integration = Repo.get_by(Integration, project_id: project_id, key: "github")

    projects = get_projects(integration.data["access_token"])
    render(conn, "select_project.html", projects: projects)
  end
end
