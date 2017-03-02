defmodule Juggler.Source.Operations.GetEnvVars do
  alias Juggler.{Repo, Source}
  require Logger
  import Monad.Result, only: [success?: 1,
                              unwrap!: 1,
                              success: 1,
                              error: 1]

  def call(source_id) do
    if source_id !=nil do
      source = Source |> Repo.get!(source_id)
      env_vars = ""
      case source.key do
          "github" -> env_vars = " -e REVISION=" <> source.data["head_commit"]["id"] <> " -e BRANCH_NAME=" <> String.replace(source.data["ref"], "refs/heads/", "")
          _ -> env_vars = ""
      end
      env_vars
    else
      ""
    end
  end

end
