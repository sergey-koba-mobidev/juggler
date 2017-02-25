defmodule Juggler.Build.Operations.ExecBuild do
  alias Juggler.{Repo, Build}
  alias Juggler.Build.Operations.{StartContainer, UpdateState, ProcessOutput,
                                  ExecCommands}
  alias Juggler.Docker.Operations.{BuildDockerImage, InjectSSHKeys,
                                  InjectSourceCode, RemoveDockerContainer}
  require Logger
  use Monad.Operators
  import Monad.Result, only: [success?: 1,
                              unwrap!: 1,
                              success: 1,
                              error: 1]

  def call(build_id) do
    # try do
      build = Build |> Repo.get!(build_id)
      result = success(build)
               ~>> fn _ -> BuildDockerImage.call(build.project_id) end
               ~>> fn _ -> StartContainer.call(build) end
               ~>> fn build -> inject_ssh_keys(build) end
               ~>> fn build -> inject_source_code(build) end
               ~>> fn build -> ExecCommands.call(build) end
               ~>> fn build -> RemoveDockerContainer.call(build.container_id) end

      if success?(result) do
        ProcessOutput.call(build, "cmd_finished", %{})
        UpdateState.call(build, "finished")
      else
        stop_build_with_error(build_id, result.error)
      end
    # rescue
    #   e -> stop_build_with_error(build_id, inspect(e))
    # end
  end

  def inject_ssh_keys(build) do
    result = InjectSSHKeys.call(build.container_id, build.project_id)
    if success?(result) do
      success(build)
    else
      result
    end
  end

  def inject_source_code(build) do
    result = InjectSourceCode.call(build.container_id, build.source_id)
    if success?(result) do
      success(build)
    else
      result
    end
  end

  def stop_build_with_error(build_id, error_msg) do
    build = Build |> Repo.get!(build_id)
    ProcessOutput.call(build, "cmd_finished_error", %{error_msg: error_msg})
    UpdateState.call(build, "error")
    RemoveDockerContainer.call(build.container_id)
  end
end
