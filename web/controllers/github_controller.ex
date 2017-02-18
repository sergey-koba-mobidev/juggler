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
                                  SetRepo, Unlink, CreatePushWebhook}


  plug Juggler.Plugs.Authenticated when not action in [:webhook]
  plug Juggler.Project.Plugs.Authenticate when not action in [:webhook]

  def setup(conn, %{"project_id" => project_id}) do
    callback_url = "http://8b64e82a.ngrok.io" <> project_github_path(conn, :callback, project_id)
    #callback_url = project_github_url(conn, :callback, project_id)
    redirect(conn, external: GetAuthorizeUrl.call(callback_url).value)
  end

  def callback(conn, %{"project_id" => project_id, "code" => code}) do
    # TODO: refactor to monad
    callback_url = "http://8b64e82a.ngrok.io" <> project_github_path(conn, :callback, project_id)
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
    webhook_url = "http://8b64e82a.ngrok.io" <> project_github_path(conn, :webhook, project_id)
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

  def webhook(conn, %{"project_id" => project_id}) do
    {:ok, body, _conn} = Plug.Conn.read_body(conn)
    Logger.info inspect(body)
    send_resp(conn, :no_content, "")
  end
  # %{"hook" => %{"active" => true, "config" => %{"content_type" => "json", "insecure_ssl" => "0", "url" => "http://8b64e82a.ngrok.io/api/projects/1/github/webhook"}, "created_at" => "2017-02-18T23:14:01Z", "events" => ["push"], "id" => 12195969, "last_response" => %{"code" => nil, "message" => nil, "status" => "unused"}, "name" => "web", "ping_url" => "https://api.github.com/repos/sergey-koba-mobidev/university-journal/hooks/12195969/pings", "test_url" => "https://api.github.com/repos/sergey-koba-mobidev/university-journal/hooks/12195969/test", "type" => "Repository", "updated_at" => "2017-02-18T23:14:01Z", "url" => "https://api.github.com/repos/sergey-koba-mobidev/university-journal/hooks/12195969"}, "hook_id" => 12195969, "project_id" => "1", "repository" => %{"statuses_url" => "https://api.github.com/repos/sergey-koba-mobidev/university-journal/statuses/{sha}", "git_refs_url" => "https://api.github.com/repos/sergey-koba-mobidev/university-journal/git/refs{/sha}", "issue_comment_url" => "https://api.github.com/repos/sergey-koba-mobidev/university-journal/issues/comments{/number}", "watchers" => 0, "mirror_url" => nil, "languages_url" => "https://api.github.com/repos/sergey-koba-mobidev/university-journal/languages", "stargazers_count" => 0, "forks" => 1, "default_branch" => "master", "comments_url" => "https://api.github.com/repos/sergey-koba-mobidev/university-journal/comments{/number}", "commits_url" => "https://api.github.com/repos/sergey-koba-mobidev/university-journal/commits{/sha}", "id" => 31128736, "clone_url" => "https://github.com/sergey-koba-mobidev/university-journal.git", "homepage" => nil, "stargazers_url" => "https://api.github.com/repos/sergey-koba-mobidev/university-journal/stargazers", "events_url" => "https://api.github.com/repos/sergey-koba-mobidev/university-journal/events", "blobs_url" => "https://api.github.com/repos/sergey-koba-mobidev/university-journal/git/blobs{/sha}", "forks_count" => 1, "pushed_at" => "2016-12-02T21:53:19Z", "git_url" => "git://github.com/sergey-koba-mobidev/university-journal.git", "hooks_url" => "https://api.github.com/repos/sergey-koba-mobidev/university-journal/hooks", "owner" => %{"avatar_url" => "https://avatars.githubusercontent.com/u/10288649?v=3", "events_url" => "https://api.github.com/users/sergey-koba-mobidev/events{/privacy}", "followers_url" => "https://api.github.com/users/sergey-koba-mobidev/followers", "following_url" => "https://api.github.com/users/sergey-koba-mobidev/following{/other_user}", "gists_url" => "https://api.github.com/users/sergey-koba-mobidev/gists{/gist_id}", "gravatar_id" => "", "html_url" => "https://github.com/sergey-koba-mobidev", "id" => 10288649, "login" => "sergey-koba-mobidev", "organizations_url" => "https://api.github.com/users/sergey-koba-mobidev/orgs", "received_events_url" => "https://api.github.com/users/sergey-koba-mobidev/received_events", "repos_url" => "https://api.github.com/users/sergey-koba-mobidev/repos", "site_admin" => false, "starred_url" => "https://api.github.com/users/sergey-koba-mobidev/starred{/owner}{/repo}", "subscriptions_url" => "https://api.github.com/users/sergey-koba-mobidev/subscriptions", "type" => "User", "url" => "https://api.github.com/users/sergey-koba-mobidev"}, "trees_url" => "https://api.github.com/repos/sergey-koba-mobidev/university-journal/git/trees{/sha}", "git_commits_url" => "https://api.github.com/repos/sergey-koba-mobidev/university-journal/git/commits{/sha}", "collaborators_url" => "https://api.github.com/repos/sergey-koba-mobidev/university-journal/collaborators{/collaborator}", "watchers_count" => 0, "tags_url" => "https://api.github.com/repos/sergey-koba-mobidev/university-journal/tags", "merges_url" => "https://api.github.com/repos/sergey-koba-mobidev/university-journal/merges", "releases_url" => "https://api.github.com/repos/sergey-koba-mobidev/university-journal/releases{/id}", "subscribers_url" => "https://api.github.com/repos/sergey-koba-mobidev/university-journal/subscribers", "ssh_url" => "git@github.com:sergey-koba-mobidev/university-journal.git", "created_at" => "2015-02-21T14:56:09Z", "name" => "university-journal", "has_issues" => true, "private" => false, "git_tags_url" => "https://api.github.com/repos/sergey-koba-mobidev/university-journal/git/tags{/sha}", "archive_url" => "https://api.github.com/repos/sergey-koba-mobidev/university-journal/{archive_format}{/ref}", "has_wiki" => true, "open_issues_count" => 0, "milestones_url" => "https://api.github.com/repos/sergey-koba-mobidev/university-journal/milestones{/number}", "forks_url" => "https://api.github.com/repos/sergey-koba-mobidev/university-journal/forks", "url" => "https://api.github.com/repos/sergey-koba-mobidev/university-journal", "downloads_url" => "https://api.github.com/repos/sergey-koba-mobidev/university-journal/downloads", "open_issues" => 0, "keys_url" => "https://api.github.com/repos/sergey-koba-mobidev/university-journal/keys{/key_id}", "description" => "A university classes manager", ...}, "sender" => %{"avatar_url" => "https://avatars.githubusercontent.com/u/10288649?v=3", "events_url" => "https://api.github.com/users/sergey-koba-mobidev/events{/privacy}", "followers_url" => "https://api.github.com/users/sergey-koba-mobidev/followers", "following_url" => "https://api.github.com/users/sergey-koba-mobidev/following{/other_user}", "gists_url" => "https://api.github.com/users/sergey-koba-mobidev/gists{/gist_id}", "gravatar_id" => "", "html_url" => "https://github.com/sergey-koba-mobidev", "id" => 10288649, "login" => "sergey-koba-mobidev", "organizations_url" => "https://api.github.com/users/sergey-koba-mobidev/orgs", "received_events_url" => "https://api.github.com/users/sergey-koba-mobidev/received_events", "repos_url" => "https://api.github.com/users/sergey-koba-mobidev/repos", "site_admin" => false, "starred_url" => "https://api.github.com/users/sergey-koba-mobidev/starred{/owner}{/repo}", "subscriptions_url" => "https://api.github.com/users/sergey-koba-mobidev/subscriptions", "type" => "User", "url" => "https://api.github.com/users/sergey-koba-mobidev"}, "zen" => "Speak like a human."}
end
