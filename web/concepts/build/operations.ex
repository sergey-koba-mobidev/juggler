defmodule Juggler.BuildOperations do
  alias Juggler.Repo
  alias Juggler.Build
  alias Juggler.Project
  alias Juggler.BuildOutput
  alias Porcelain.Result
  require Logger
  use Monad.Operators
  import Monad.Result, only: [success?: 1,
                              unwrap!: 1,
                              success: 1,
                              error: 1]

  #TODO: split to separate operations
  def exec_build(build_id) do
    build = Build |> Repo.get!(build_id)
    result = success(build)
             ~>> fn build -> start_docker_container(build) end
             ~>> fn build -> exec_commands(build, get_commands_arr(build.commands)) end
             ~>> fn build -> remove_docker_container(build) end

    if success?(result) do
      build = unwrap!(result)
      process_build_output(build, "cmd_finished", %{})
      update_build_state(build, "finished")
    else
      build = Build |> Repo.get!(build_id)
      process_build_output(build, "cmd_finished_error", %{error_msg: result.error})
      update_build_state(build, "error")
      remove_docker_container(build)
    end
  end

  # Starts new docker container and saves it's id to build
  def start_docker_container(build) do
    project = Project |> Repo.get!(build.project_id)
    docker_image = project.docker_image
    if docker_image == nil do
      error("Project environment is not configured, please select docker image in settings")
    else
      %Result{out: output, status: status} = Porcelain.shell("docker run -it -d " <> get_docker_env_vars_string(project) <> docker_image <> " /bin/bash", err: :out)
      case status do
        0 ->
          container_id = String.trim(output, "\n")
          changeset = Build.changeset(build, %{:container_id => container_id})
          case Repo.update(changeset) do
            {:ok, build} ->
              Logger.info " ---> New docker cont " <> container_id <> " build: " <> Integer.to_string(build.id)
              update_build_state(build, "running")
              success(build)
            {:error, _changeset} ->
              error_msg = "Error updating build " <> Integer.to_string(build.id) <> " container_id to " <> container_id
              Logger.error error_msg
              error(error_msg)
          end
        _ -> error("Failed to start docker cont: " <> output)
      end
    end
  end

  def remove_docker_container(build) do
    %Result{out: output, status: status} = Porcelain.shell("docker inspect -f {{.State.Running}} " <> build.container_id, err: :out)
    if status == 0 do
      %Result{out: output, status: status} = Porcelain.shell("docker rm -f " <> build.container_id, err: :out)
      case status do
        0 ->
          Logger.info " ---> Removed docker cont " <> build.container_id <> " build: " <> Integer.to_string(build.id)
          success(build)
        _ -> error("Failed to remove docker cont: " <> output)
      end
    else
      error("No docker cont found " <> build.container_id)
    end
  end

  def get_docker_env_vars_string(project) do
    vars_arr = String.split(project.env_vars, "\r\n", trim: true)
    vars_str = Enum.join(vars_arr, " -e ")
    if vars_str != "", do: vars_str = " -e " <> vars_str <> " "
    vars_str
  end

  def get_commands_arr(commands) do
    String.split(commands, "\r\n")
  end

  # Executes build commands in docker container
  def exec_commands(build, commands) do
    case List.pop_at(commands, 0) do
      {nil, []} ->
        success(build)
      {cmd, cmds} ->
        {:ok, status} = exec_command(build, cmd)
        case status == 0 do
          true  -> exec_commands(build, cmds)
          false -> error("Command " <> cmd <> " failed.")
        end
    end
  end

  # Executes build command in docker container
  def exec_command(build, command) do
    Logger.info " ---> Executing build " <> Integer.to_string(build.id) <> " cmd: " <> inspect(command)
    process_build_output(build, "cmd_start", %{cmd: command})
    # TODO: refactor to streams
    docker_command = "docker exec " <> build.container_id <> " " <> command
    %Result{out: output, status: status} = Porcelain.shell(docker_command, err: :out)
    process_build_output(build, "cmd_data", %{output: output, cmd: command})
    process_build_output(build, "cmd_result", %{status: status, cmd: command})
    Logger.info " ---> Finished cmd " <> Integer.to_string(build.id) <> " cmd: " <> inspect(command) <> " result: " <> Integer.to_string(status)
    {:ok, status}
  end

  # Writes command output to database and sends to the build channel
  def process_build_output(build, event, payload) do
    changeset = BuildOutput.changeset(%BuildOutput{}, %{
      :build_id => build.id,
      :event => event,
      :payload => payload
    })

    case Repo.insert(changeset) do
      {:ok, _build_output} ->
        Juggler.Endpoint.broadcast("build:" <> Integer.to_string(build.id), event, payload)
      {:error, _changeset} ->
        Logger.error "Error inserting BuildOutput for build " <> Integer.to_string(build.id)
    end
  end

  def update_build_state(build, new_state) do
    changeset = Build.changeset(build, %{:state => new_state})

    case Repo.update(changeset) do
      {:ok, _user} ->
        Logger.info " ---> New build " <> Integer.to_string(build.id) <> " state: " <> new_state
      {:error, _changeset} ->
        Logger.error "Error updating build " <> Integer.to_string(build.id) <> " state to " <> new_state
    end
  end
end
