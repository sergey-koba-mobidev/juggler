defmodule Juggler.Build.Operations.ExecCommands do
  require Logger
  alias Juggler.Build.Operations.ProcessOutput
  alias Porcelain.Result
  import Monad.Result, only: [success?: 1,
                              unwrap!: 1,
                              success: 1,
                              error: 1]

  def call(build) do
    exec_commands(build, get_commands_arr(build.commands))
  end

  def get_commands_arr(commands) do
    case commands == nil do
      false -> String.split(commands, "\r\n")
      true  -> []
    end
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
    ProcessOutput.call(build, "cmd_start", %{cmd: command})
    # TODO: refactor to streams
    docker_command = "docker exec " <> build.container_id <> " " <> command
    %Result{out: output, status: status} = Porcelain.shell(docker_command, err: :out)
    ProcessOutput.call(build, "cmd_data", %{output: output, cmd: command})
    ProcessOutput.call(build, "cmd_result", %{status: status, cmd: command})
    Logger.info " ---> Finished cmd " <> Integer.to_string(build.id) <> " cmd: " <> inspect(command) <> " result: " <> Integer.to_string(status)
    {:ok, status}
  end
end
