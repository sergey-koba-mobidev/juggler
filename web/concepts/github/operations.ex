defmodule Juggler.GitHubOperations do

  def config(callback_url) do
    %GithubOauth.Config{
      client_id: System.get_env("GITHUB_CLIENT_ID"),
      secret: System.get_env("GITHUB_CLIENT_SECRET"),
      callback_url: callback_url,
      scope: "repo admin:repo_hook"
    }
  end

  def get_authorize_url(callback_url) do
    GithubOauth.get_authorize_url(config(callback_url))
  end

  def get_access_token(callback_url, code) do
    GithubOauth.get_token(config(callback_url), code)
  end

  def get_projects(access_token) do
    client = Tentacat.Client.new(%{access_token: access_token})
    Tentacat.Repositories.list_mine(client)
  end
end
