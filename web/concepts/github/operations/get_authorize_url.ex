defmodule Juggler.GitHub.Operations.GetAuthorizeUrl do
  import Juggler.GitHub.Helpers
  import Monad.Result, only: [success?: 1,
                              unwrap!: 1,
                              success: 1,
                              error: 1]

  def call(callback_url) do
    success(GithubOauth.get_authorize_url(config(callback_url)))
  end

end
