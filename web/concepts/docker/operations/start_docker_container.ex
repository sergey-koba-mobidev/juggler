defmodule Juggler.Docker.Operations.StartDockerContainer do
  alias Porcelain.Result
  alias Juggler.Repo
  alias Juggler.Project
  require Logger
  import Monad.Result, only: [success?: 1,
                              unwrap!: 1,
                              success: 1,
                              error: 1]

  def call(project_id, custom_params \\ "") do
    project = Project |> Repo.get!(project_id)
    docker_image = project.docker_image
    if docker_image == nil do
      error("Project environment is not configured, please select docker image in settings")
    else
      Logger.info "--> docker run -it -d -w=\"/juggler_app\" " <> custom_params <> " " <> get_docker_env_vars_string(project) <> docker_image <> " /bin/bash"
      %Result{out: output, status: status} = Porcelain.shell("docker run -it -d -w=\"/juggler_app\" " <> custom_params <> " " <> get_docker_env_vars_string(project) <> docker_image <> " /bin/bash", err: :out)
      case status do
        0 ->
          container_id = String.trim(output, "\n")
          success(container_id)
        _ -> error("Failed to start docker cont: " <> output)
      end
    end
  end

  def get_docker_env_vars_string(project) do
    vars_arr = String.split(project.env_vars || "", "\r\n", trim: true)
    vars_str = Enum.join(vars_arr, " -e ")
    if vars_str != "", do: vars_str = " -e " <> vars_str <> " "
    vars_str
  end
end
