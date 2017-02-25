defmodule Juggler.GithubController do
  use Juggler.Web, :controller
  alias Juggler.{Project, Integration}
  require Logger
  use Monad.Operators
  import Monad.Result, only: [success?: 1,
                              unwrap!: 1,
                              success: 1,
                              error: 1]
  alias Juggler.GitHub.Operations.{ProcessCallback, GetRepos, GetAuthorizeUrl,
                                  SetRepo, Unlink, CreatePushWebhook, ProcessWebhook}


  plug Juggler.Plugs.Authenticated when not action in [:webhook]
  plug Juggler.Project.Plugs.Authenticate when not action in [:webhook]

  def setup(conn, %{"project_id" => project_id}) do
    callback_url = "http://684d6acd.ngrok.io" <> project_github_path(conn, :callback, project_id)
    #callback_url = project_github_url(conn, :callback, project_id)
    redirect(conn, external: GetAuthorizeUrl.call(callback_url).value)
  end

  def callback(conn, %{"project_id" => project_id, "code" => code}) do
    # TODO: refactor to monad
    callback_url = "http://684d6acd.ngrok.io" <> project_github_path(conn, :callback, project_id)
    #callback_url = project_github_url(conn, :callback, project_id)

    result = ProcessCallback.call(project_id, callback_url, code)
    case success?(result) do
      true->
        conn
        |> put_flash(:info, "Got access to GitHub!")
        |> redirect(to: project_github_path(conn, :select_repo, project_id))
      false ->
        conn
        |> put_flash(:error, "Unable to integrate GitHub.")
        |> redirect(to: project_path(conn, :edit, project_id))
    end
  end

  def select_repo(conn, %{"project_id" => project_id}) do
    integration = Repo.get_by(Integration, project_id: project_id, key: "github")
    project = Project |> Repo.get!(project_id)

    result = GetRepos.call(integration.data["access_token"])
    case success?(result) do
      true->
        repos = result.value
        render(conn, "select_repo.html", repos: repos, project: project)
      false ->
        conn
        |> put_flash(:error, "Unable to get repos from GitHub.")
        |> redirect(to: project_path(conn, :edit, project_id))
    end
  end

  def set_repo(conn, %{"project_id" => project_id, "set_project" => %{"owner" => owner, "repo" => repo}}) do
    integration = Repo.get_by(Integration, project_id: project_id, key: "github")
    webhook_url = "http://684d6acd.ngrok.io" <> project_github_path(conn, :webhook, project_id)
    #webhook_url = project_github_url(conn, :webhook, project_id)

    result = success(nil)
              ~>> fn _ -> SetRepo.call(owner, repo, integration) end
              ~>> fn integration -> CreatePushWebhook.call(owner, repo, integration, webhook_url) end

    case success?(result) do
      true->
        conn
        |> put_flash(:info, "GitHub is integrated!")
        |> redirect(to: project_path(conn, :edit, project_id))
      false ->
        conn
        |> put_flash(:error, result.error)
        |> redirect(to: project_path(conn, :edit, project_id))
    end
  end

  def unlink(conn, %{"project_id" => project_id}) do
    integration = Repo.get_by(Integration, project_id: project_id, key: "github")

    result = Unlink.call(integration)
    case success?(result) do
      true->
        conn
        |> put_flash(:info, "GitHub is unlinked!")
        |> redirect(to: project_path(conn, :edit, project_id))
      false ->
        conn
        |> put_flash(:error, "Unable to unlink for GitHub integration.")
        |> redirect(to: project_path(conn, :edit, project_id))
    end
  end

  def webhook(conn, params = %{"project_id" => project_id}) do
    result = ProcessWebhook.call(project_id, params)
    send_resp(conn, :no_content, "")
  end
end
