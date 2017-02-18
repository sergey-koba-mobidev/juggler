defmodule Juggler.GitHub.Operations.GetRepo do
  import Monad.Result, only: [success?: 1,
                              unwrap!: 1,
                              success: 1,
                              error: 1]

  def call(owner, repo, access_token) do
    client = Tentacat.Client.new(%{access_token: access_token})
    success(Tentacat.Repositories.repo_get(owner, repo, client))
  end

end
