defmodule Juggler.Deploy.Operations.ExecDeploy do
  alias Juggler.{Repo, Deploy, Build}
  alias Juggler.Deploy.Operations.{StartContainer, UpdateState, ProcessOutput,
                                  ExecCommands}
  alias Juggler.Docker.Operations.{BuildDockerImage, InjectSSHKeys,
                                  InjectSourceCode, RemoveDockerContainer}
  require Logger
  use Monad.Operators
  import Monad.Result, only: [success?: 1,
                              unwrap!: 1,
                              success: 1,
                              error: 1]

  def call(deploy_id) do
    # try do
      deploy = Deploy |> Repo.get!(deploy_id)
      result = success(deploy)
               ~>> fn _ -> BuildDockerImage.call(deploy.project_id) end
               ~>> fn _ -> StartContainer.call(deploy) end
               ~>> fn deploy -> inject_ssh_keys(deploy) end
               ~>> fn deploy -> inject_source_code(deploy) end
               ~>> fn deploy -> ExecCommands.call(deploy) end
               ~>> fn deploy -> RemoveDockerContainer.call(deploy.container_id) end

      if success?(result) do
        ProcessOutput.call(deploy, "cmd_finished", %{})
        UpdateState.call(deploy, "finished")
      else
        stop_deploy_with_error(deploy_id, result.error)
      end
    # rescue
    #   e -> stop_deploy_with_error(deploy_id, inspect(e))
    # end
  end

  def inject_ssh_keys(deploy) do
    result = InjectSSHKeys.call(deploy.container_id, deploy.project_id)
    if success?(result) do
      success(deploy)
    else
      result
    end
  end

  def inject_source_code(deploy) do
    build = Build |> Repo.get!(deploy.build_id)
    result = InjectSourceCode.call(deploy.container_id, build.source_id)
    if success?(result) do
      success(deploy)
    else
      result
    end
  end

  def stop_deploy_with_error(deploy_id, error_msg) do
    deploy = Deploy |> Repo.get!(deploy_id)
    ProcessOutput.call(deploy, "cmd_finished_error", %{error_msg: error_msg})
    if deploy.state != "stopped" do
      UpdateState.call(deploy, "error")
      RemoveDockerContainer.call(deploy.container_id)
    end
  end
end
