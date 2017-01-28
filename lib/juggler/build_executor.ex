defmodule Juggler.BuildExecutor do
  alias Porcelain.Process, as: Proc
  alias Porcelain.Result
  require Logger

  def exec_commands(build_id, commands) do
    commands_arr = String.split(commands, "\n")
    for command <- commands_arr do
      exec_command(build_id, String.trim(command, "\r"))
    end
  end

  def exec_command(build_id, command) do
    Logger.info "Executing build " <> Integer.to_string(build_id) <> " cmd: " <> inspect(command)
    Juggler.Endpoint.broadcast("build:" <> Integer.to_string(build_id), "cmd_start", %{cmd: command})
    proc = %Proc{pid: pid} = Porcelain.spawn_shell(command, out: {:send, self()})
    receive do
      {^pid, :data, :out, data} -> Juggler.Endpoint.broadcast("build:" <> Integer.to_string(build_id), "cmd_data", %{output: data, cmd: command})
    end
    receive do
      {^pid, :result, %Result{status: status}} -> Juggler.Endpoint.broadcast("build:" <> Integer.to_string(build_id), "cmd_result", %{status: status, cmd: command})
    end
  end
end
