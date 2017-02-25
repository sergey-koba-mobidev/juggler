defmodule Juggler.Docker.Operations.InjectSourceCode do
  alias Porcelain.Result
  alias Juggler.{Repo, Project, Integration, Source}
  require Logger
  use Monad.Operators
  import Monad.Result, only: [success: 1,
                              error: 1]

  def call(container_id, source_id) do
    if source_id == nil do
      success(source_id)
    else
      source = Source |> Repo.get!(source_id)
      case source.key do
        "github" -> inject_github_source(container_id, source)
        _ -> error("Can't inject Unknown source")
      end
    end
  end

  def inject_github_source(container_id, source) do
    success(nil)
      ~>> fn _ -> git_clone(container_id, source) end
      ~>> fn _ -> git_checkout(container_id, source) end
  end

  def git_clone(container_id, source) do
    Logger.info " ---> Clone git repo for source " <> Integer.to_string(source.id)
    docker_command = "docker exec " <> container_id <> " git clone " <> clone_url(source) <> " ."
    %Result{out: output, status: status} = Porcelain.shell(docker_command, err: :out)
    Logger.info " ---> Cloned git repo for source " <> Integer.to_string(source.id) <> " result: " <> Integer.to_string(status)
    case status do
      0 -> success(container_id)
      _ -> error(output)
    end
  end

  def clone_url(source) do
    integration = Repo.get_by(Integration, project_id: source.project_id, key: "github")
    String.replace(source.data["repository"]["clone_url"], "https://", "https://" <> integration.data["access_token"] <> "@")
  end

  def git_checkout(container_id, source) do
    Logger.info " ---> Checkout git revision for source " <> Integer.to_string(source.id)
    docker_command = "docker exec " <> container_id <> " git checkout " <> source.data["head_commit"]["id"] <> " ."
    %Result{out: output, status: status} = Porcelain.shell(docker_command, err: :out)
    Logger.info " ---> Checkouted git revision for source " <> Integer.to_string(source.id) <> " result: " <> Integer.to_string(status)
    case status do
      0 -> success(container_id)
      _ -> error(output)
    end
  end
end
