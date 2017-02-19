defmodule Juggler.Build.Operations.InjectSourceCode do
  alias Porcelain.Result
  alias Juggler.Repo
  alias Juggler.Project
  require Logger
  import Monad.Result, only: [success: 1,
                              error: 1]

  def call(build) do
    if build.source_id == nil do
      success(build)
    else
      source = Source |> Repo.get!(build.source_id)
      case source.key do
        "github" -> inject_github_source(build, source)
        _ -> error("Can't inject Unknown source")
      end
    end
  end

  def inject_github_source(build, source) do
    # git clone https://07467a6abb4160be6695a287446afda0a41ddd26@github.com/sergey-koba-mobidev/university-journal.git .
    # git checkout 4ce482eecf3b7ce1e4ab0611bb0498a9796c03e7
  end
end
