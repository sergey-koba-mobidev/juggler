defmodule Juggler.Build.Operations.InjectSourceCode do
  alias Porcelain.Result
  alias Juggler.{Repo, Project, Integration, Source}
  require Logger
  use Monad.Operators
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

  # git clone https://07467a6abb4160be6695a287446afda0a41ddd26@github.com/sergey-koba-mobidev/university-journal.git .
  # git checkout 4ce482eecf3b7ce1e4ab0611bb0498a9796c03e7
  def inject_github_source(build, source) do
    success(nil)
      ~>> fn _ -> git_clone(build, source) end
      ~>> fn _ -> git_checkout(build, source) end
  end

  def git_clone(build, source) do
    Logger.info " ---> Clone git repo for source " <> Integer.to_string(source.id)
    docker_command = "docker exec " <> build.container_id <> " git clone " <> clone_url(build, source) <> " ."
    %Result{out: output, status: status} = Porcelain.shell(docker_command, err: :out)
    Logger.info " ---> Cloned git repo for source " <> Integer.to_string(source.id) <> " result: " <> Integer.to_string(status)
    case status do
      0 -> success(build)
      _ -> error(output)
    end
  end

  def clone_url(build, source) do
    integration = Repo.get_by(Integration, project_id: build.project_id, key: "github")
    String.replace(source.data["repository"]["clone_url"], "https://", "https://" <> integration.data["access_token"] <> "@")
  end

  def git_checkout(build, source) do
    Logger.info " ---> Checkout git revision for source " <> Integer.to_string(source.id)
    docker_command = "docker exec " <> build.container_id <> " git checkout " <> source.data["head_commit"]["id"] <> " ."
    %Result{out: output, status: status} = Porcelain.shell(docker_command, err: :out)
    Logger.info " ---> Checkouted git revision for source " <> Integer.to_string(source.id) <> " result: " <> Integer.to_string(status)
    case status do
      0 -> success(build)
      _ -> error(output)
    end
  end
end
