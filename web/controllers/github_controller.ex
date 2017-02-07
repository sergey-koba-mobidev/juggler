defmodule Juggler.GithubController do
  use Juggler.Web, :controller
  import Juggler.GitHubOperations
  alias Juggler.Integration
  require Logger

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
        |> redirect(to: project_path(conn, :edit, project_id))
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Unable to integrate GitHub.")
        |> redirect(to: project_path(conn, :edit, project_id))
    end
  end
end
