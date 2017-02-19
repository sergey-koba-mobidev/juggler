defmodule Juggler.GitHub.Operations.ProcessWebhook do
  alias Juggler.Repo
  alias Juggler.Project
  require Logger
  use Monad.Operators
  import Monad.Result, only: [success?: 1,
                              unwrap!: 1,
                              success: 1,
                              error: 1]

  def call(project_id, webhook) do

  end
end
