defmodule Juggler.GitHub.Helpers do
  def config(callback_url) do
    %GithubOauth.Config{
      client_id: System.get_env("GITHUB_CLIENT_ID"),
      secret: System.get_env("GITHUB_CLIENT_SECRET"),
      callback_url: callback_url,
      scope: "repo admin:repo_hook"
    }
  end
end
