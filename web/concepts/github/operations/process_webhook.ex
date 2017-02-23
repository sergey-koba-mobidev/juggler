defmodule Juggler.GitHub.Operations.ProcessWebhook do
  alias Juggler.{Repo, Source, Build, Project}
  alias Juggler.Build.Operations.StartBuild
  require Logger
  use Monad.Operators
  import Monad.Result, only: [success?: 1,
                              unwrap!: 1,
                              success: 1,
                              error: 1]

  def call(project_id, webhook) do
    result = success(nil)
              ~>> fn _ -> save_source(project_id, webhook) end
              ~>> fn source -> create_build(project_id, source) end

    case success?(result) do
      true  -> success(result.value)
      false -> error(result.error)
    end
  end

  def save_source(project_id, webhook) do
    changeset = Source.changeset(%Source{}, %{
      :project_id => project_id,
      :key => "github",
      :data => webhook
    })

    case Repo.insert(changeset) do
      {:ok, source} ->
        success(source)
      {:error, _changeset} ->
        error("Unable to save Webhook")
    end
  end

  def create_build(project_id, source) do
    project = Project |> Repo.get!(project_id)

    if success?(Juggler.Project.Operations.CheckBranch.call(project, source.data["ref"])) do
      changeset = Build.changeset(%Build{}, %{
        :project_id => project_id,
        :key => source.data["head_commit"]["message"],
        :state => "new",
        :source_id => source.id,
        :commands => project.build_commands
      })

      case Repo.insert(changeset) do
        {:ok, build} ->
          StartBuild.call(build)
          success(build)
        {:error, _changeset} ->
          error("Can't create build with webhook")
      end
    else
      success(nil)
    end
  end
end

# {
#   "ref": "refs/heads/master",
#   "before": "dec7621fe590b383ddf61734dcfb045035e5b628",
#   "after": "4ce482eecf3b7ce1e4ab0611bb0498a9796c03e7",
#   "created": false,
#   "deleted": false,
#   "forced": false,
#   "base_ref": null,
#   "compare": "https://github.com/sergey-koba-mobidev/university-journal/compare/dec7621fe590...4ce482eecf3b",
#   "commits": [
#     {
#       "id": "4ce482eecf3b7ce1e4ab0611bb0498a9796c03e7",
#       "tree_id": "449533d18ba03b46e1ff4a036291917cc0fb6e00",
#       "distinct": true,
#       "message": "update TODO",
#       "timestamp": "2017-02-19T17:35:30+02:00",
#       "url": "https://github.com/sergey-koba-mobidev/university-journal/commit/4ce482eecf3b7ce1e4ab0611bb0498a9796c03e7",
#       "author": {
#         "name": "Sergey Koba",
#         "email": "s.koba@mobidev.biz",
#         "username": "sergey-koba-mobidev"
#       },
#       "committer": {
#         "name": "Sergey Koba",
#         "email": "s.koba@mobidev.biz",
#         "username": "sergey-koba-mobidev"
#       },
#       "added": [
#
#       ],
#       "removed": [
#
#       ],
#       "modified": [
#         "README.md"
#       ]
#     }
#   ],
#   "head_commit": {
#     "id": "4ce482eecf3b7ce1e4ab0611bb0498a9796c03e7",
#     "tree_id": "449533d18ba03b46e1ff4a036291917cc0fb6e00",
#     "distinct": true,
#     "message": "update TODO",
#     "timestamp": "2017-02-19T17:35:30+02:00",
#     "url": "https://github.com/sergey-koba-mobidev/university-journal/commit/4ce482eecf3b7ce1e4ab0611bb0498a9796c03e7",
#     "author": {
#       "name": "Sergey Koba",
#       "email": "s.koba@mobidev.biz",
#       "username": "sergey-koba-mobidev"
#     },
#     "committer": {
#       "name": "Sergey Koba",
#       "email": "s.koba@mobidev.biz",
#       "username": "sergey-koba-mobidev"
#     },
#     "added": [
#
#     ],
#     "removed": [
#
#     ],
#     "modified": [
#       "README.md"
#     ]
#   },
#   "repository": {
#     "id": 31128736,
#     "name": "university-journal",
#     "full_name": "sergey-koba-mobidev/university-journal",
#     "owner": {
#       "name": "sergey-koba-mobidev",
#       "email": "s.koba@mobidev.biz",
#       "login": "sergey-koba-mobidev",
#       "id": 10288649,
#       "avatar_url": "https://avatars.githubusercontent.com/u/10288649?v=3",
#       "gravatar_id": "",
#       "url": "https://api.github.com/users/sergey-koba-mobidev",
#       "html_url": "https://github.com/sergey-koba-mobidev",
#       "followers_url": "https://api.github.com/users/sergey-koba-mobidev/followers",
#       "following_url": "https://api.github.com/users/sergey-koba-mobidev/following{/other_user}",
#       "gists_url": "https://api.github.com/users/sergey-koba-mobidev/gists{/gist_id}",
#       "starred_url": "https://api.github.com/users/sergey-koba-mobidev/starred{/owner}{/repo}",
#       "subscriptions_url": "https://api.github.com/users/sergey-koba-mobidev/subscriptions",
#       "organizations_url": "https://api.github.com/users/sergey-koba-mobidev/orgs",
#       "repos_url": "https://api.github.com/users/sergey-koba-mobidev/repos",
#       "events_url": "https://api.github.com/users/sergey-koba-mobidev/events{/privacy}",
#       "received_events_url": "https://api.github.com/users/sergey-koba-mobidev/received_events",
#       "type": "User",
#       "site_admin": false
#     },
#     "private": false,
#     "html_url": "https://github.com/sergey-koba-mobidev/university-journal",
#     "description": "A university classes manager",
#     "fork": false,
#     "url": "https://github.com/sergey-koba-mobidev/university-journal",
#     "forks_url": "https://api.github.com/repos/sergey-koba-mobidev/university-journal/forks",
#     "keys_url": "https://api.github.com/repos/sergey-koba-mobidev/university-journal/keys{/key_id}",
#     "collaborators_url": "https://api.github.com/repos/sergey-koba-mobidev/university-journal/collaborators{/collaborator}",
#     "teams_url": "https://api.github.com/repos/sergey-koba-mobidev/university-journal/teams",
#     "hooks_url": "https://api.github.com/repos/sergey-koba-mobidev/university-journal/hooks",
#     "issue_events_url": "https://api.github.com/repos/sergey-koba-mobidev/university-journal/issues/events{/number}",
#     "events_url": "https://api.github.com/repos/sergey-koba-mobidev/university-journal/events",
#     "assignees_url": "https://api.github.com/repos/sergey-koba-mobidev/university-journal/assignees{/user}",
#     "branches_url": "https://api.github.com/repos/sergey-koba-mobidev/university-journal/branches{/branch}",
#     "tags_url": "https://api.github.com/repos/sergey-koba-mobidev/university-journal/tags",
#     "blobs_url": "https://api.github.com/repos/sergey-koba-mobidev/university-journal/git/blobs{/sha}",
#     "git_tags_url": "https://api.github.com/repos/sergey-koba-mobidev/university-journal/git/tags{/sha}",
#     "git_refs_url": "https://api.github.com/repos/sergey-koba-mobidev/university-journal/git/refs{/sha}",
#     "trees_url": "https://api.github.com/repos/sergey-koba-mobidev/university-journal/git/trees{/sha}",
#     "statuses_url": "https://api.github.com/repos/sergey-koba-mobidev/university-journal/statuses/{sha}",
#     "languages_url": "https://api.github.com/repos/sergey-koba-mobidev/university-journal/languages",
#     "stargazers_url": "https://api.github.com/repos/sergey-koba-mobidev/university-journal/stargazers",
#     "contributors_url": "https://api.github.com/repos/sergey-koba-mobidev/university-journal/contributors",
#     "subscribers_url": "https://api.github.com/repos/sergey-koba-mobidev/university-journal/subscribers",
#     "subscription_url": "https://api.github.com/repos/sergey-koba-mobidev/university-journal/subscription",
#     "commits_url": "https://api.github.com/repos/sergey-koba-mobidev/university-journal/commits{/sha}",
#     "git_commits_url": "https://api.github.com/repos/sergey-koba-mobidev/university-journal/git/commits{/sha}",
#     "comments_url": "https://api.github.com/repos/sergey-koba-mobidev/university-journal/comments{/number}",
#     "issue_comment_url": "https://api.github.com/repos/sergey-koba-mobidev/university-journal/issues/comments{/number}",
#     "contents_url": "https://api.github.com/repos/sergey-koba-mobidev/university-journal/contents/{+path}",
#     "compare_url": "https://api.github.com/repos/sergey-koba-mobidev/university-journal/compare/{base}...{head}",
#     "merges_url": "https://api.github.com/repos/sergey-koba-mobidev/university-journal/merges",
#     "archive_url": "https://api.github.com/repos/sergey-koba-mobidev/university-journal/{archive_format}{/ref}",
#     "downloads_url": "https://api.github.com/repos/sergey-koba-mobidev/university-journal/downloads",
#     "issues_url": "https://api.github.com/repos/sergey-koba-mobidev/university-journal/issues{/number}",
#     "pulls_url": "https://api.github.com/repos/sergey-koba-mobidev/university-journal/pulls{/number}",
#     "milestones_url": "https://api.github.com/repos/sergey-koba-mobidev/university-journal/milestones{/number}",
#     "notifications_url": "https://api.github.com/repos/sergey-koba-mobidev/university-journal/notifications{?since,all,participating}",
#     "labels_url": "https://api.github.com/repos/sergey-koba-mobidev/university-journal/labels{/name}",
#     "releases_url": "https://api.github.com/repos/sergey-koba-mobidev/university-journal/releases{/id}",
#     "deployments_url": "https://api.github.com/repos/sergey-koba-mobidev/university-journal/deployments",
#     "created_at": 1424530569,
#     "updated_at": "2016-01-23T18:40:23Z",
#     "pushed_at": 1487518536,
#     "git_url": "git://github.com/sergey-koba-mobidev/university-journal.git",
#     "ssh_url": "git@github.com:sergey-koba-mobidev/university-journal.git",
#     "clone_url": "https://github.com/sergey-koba-mobidev/university-journal.git",
#     "svn_url": "https://github.com/sergey-koba-mobidev/university-journal",
#     "homepage": null,
#     "size": 249,
#     "stargazers_count": 0,
#     "watchers_count": 0,
#     "language": "Ruby",
#     "has_issues": true,
#     "has_downloads": true,
#     "has_wiki": true,
#     "has_pages": false,
#     "forks_count": 1,
#     "mirror_url": null,
#     "open_issues_count": 0,
#     "forks": 1,
#     "open_issues": 0,
#     "watchers": 0,
#     "default_branch": "master",
#     "stargazers": 0,
#     "master_branch": "master"
#   },
#   "pusher": {
#     "name": "sergey-koba-mobidev",
#     "email": "s.koba@mobidev.biz"
#   },
#   "sender": {
#     "login": "sergey-koba-mobidev",
#     "id": 10288649,
#     "avatar_url": "https://avatars.githubusercontent.com/u/10288649?v=3",
#     "gravatar_id": "",
#     "url": "https://api.github.com/users/sergey-koba-mobidev",
#     "html_url": "https://github.com/sergey-koba-mobidev",
#     "followers_url": "https://api.github.com/users/sergey-koba-mobidev/followers",
#     "following_url": "https://api.github.com/users/sergey-koba-mobidev/following{/other_user}",
#     "gists_url": "https://api.github.com/users/sergey-koba-mobidev/gists{/gist_id}",
#     "starred_url": "https://api.github.com/users/sergey-koba-mobidev/starred{/owner}{/repo}",
#     "subscriptions_url": "https://api.github.com/users/sergey-koba-mobidev/subscriptions",
#     "organizations_url": "https://api.github.com/users/sergey-koba-mobidev/orgs",
#     "repos_url": "https://api.github.com/users/sergey-koba-mobidev/repos",
#     "events_url": "https://api.github.com/users/sergey-koba-mobidev/events{/privacy}",
#     "received_events_url": "https://api.github.com/users/sergey-koba-mobidev/received_events",
#     "type": "User",
#     "site_admin": false
#   }
# }
