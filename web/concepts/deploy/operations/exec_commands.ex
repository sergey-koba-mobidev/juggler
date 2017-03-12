defmodule Juggler.Deploy.Operations.ExecCommands do
  require Logger
  alias Juggler.Deploy.Operations.ProcessOutput
  alias Porcelain.Result
  alias Porcelain.Process, as: Proc
  import Monad.Result, only: [success?: 1,
                              unwrap!: 1,
                              success: 1,
                              error: 1]

  def call(deploy) do
    exec_commands(deploy, get_commands_arr(deploy.commands))
  end

  def get_commands_arr(commands) do
    case commands == nil do
      false -> String.split(commands, "\r\n")
      true  -> []
    end
  end

  # Executes deploy commands in docker container
  def exec_commands(deploy, commands) do
    case List.pop_at(commands, 0) do
      {nil, []} ->
        success(deploy)
      {cmd, cmds} ->
        {:ok, status} = exec_command(deploy, cmd)
        case status == 0 do
          true  -> exec_commands(deploy, cmds)
          false -> error("Command " <> cmd <> " failed.")
        end
    end
  end

  # Executes deploy command in docker container
  def exec_command(deploy, command) do
    Logger.info " ---> Executing deploy " <> Integer.to_string(deploy.id) <> " cmd: " <> inspect(command)
    ProcessOutput.call(deploy, "cmd_start", %{cmd: command})

    docker_command = "docker exec " <> deploy.container_id <> " " <> command
    proc = %Proc{out: outstream} = Porcelain.spawn_shell(docker_command, out: :stream, err: :out, result: :keep)
    Enum.each(outstream, fn(output) -> ProcessOutput.call(deploy, "cmd_data", %{output: output, cmd: command}) end)
    {:ok, %Result{status: status}} = Proc.await(proc, elem(Integer.parse(System.get_env("COMMAND_TIMEOUT")),0))

    ProcessOutput.call(deploy, "cmd_result", %{status: status, cmd: command})
    Logger.info " ---> Finished cmd " <> Integer.to_string(deploy.id) <> " cmd: " <> inspect(command) <> " result: " <> Integer.to_string(status)
    {:ok, status}
  end
end
