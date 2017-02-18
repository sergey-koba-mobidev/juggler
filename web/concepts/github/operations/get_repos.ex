defmodule Juggler.GitHub.Operations.GetRepos do
  import Monad.Result, only: [success?: 1,
                              unwrap!: 1,
                              success: 1,
                              error: 1]

  def call(access_token) do
    client = Tentacat.Client.new(%{access_token: access_token})
    success(Tentacat.Repositories.list_mine(client, type: "owner"))
  end

end
