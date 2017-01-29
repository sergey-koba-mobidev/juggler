defmodule Juggler.BuildServer do
  use GenServer
  alias Juggler.Repo
  alias Juggler.Build
  alias Porcelain.Process, as: Proc
  alias Porcelain.Result
  require Logger

  def start_link(opts \\ []) do
    {:ok, pid} = GenServer.start_link(__MODULE__, [], opts)
  end

  def new_build(build_id) do
    GenServer.cast(:build_server, {:new_build, build_id})
  end

  def handle_cast({:new_build, build_id}, state) do
    build = Build |> Repo.get!(build_id) |> Repo.preload([:project])
    commands_arr = String.split(build.project.build_commands, "\n")
    Logger.info " ---> Started build " <> build_id <> " commands: " <> inspect(commands_arr)
    spawn fn -> exec_commands(build.id, commands_arr) end
    {:noreply, [build_id | state]}
  end

  def exec_commands(build_id, commands) do
    case List.pop_at(commands, 0) do
      {nil, []} ->
        Juggler.Endpoint.broadcast("build:" <> Integer.to_string(build_id), "cmd_finished", %{})
      {cmd, cmds} ->
        {:ok, status} = exec_command(build_id, String.trim(cmd, "\r"))
        case status == 0 do
          true  -> exec_commands(build_id, cmds)
          false -> Juggler.Endpoint.broadcast("build:" <> Integer.to_string(build_id), "cmd_finished_error", %{})
        end
    end
  end

  def exec_command(build_id, command) do
    Logger.info " ---> Executing build " <> Integer.to_string(build_id) <> " cmd: " <> inspect(command)
    Juggler.Endpoint.broadcast("build:" <> Integer.to_string(build_id), "cmd_start", %{cmd: command})
    # TODO: refactor to streams
    %Result{out: output, status: status} = Porcelain.shell(command, err: :out)
    Juggler.Endpoint.broadcast("build:" <> Integer.to_string(build_id), "cmd_data", %{output: output, cmd: command})
    Juggler.Endpoint.broadcast("build:" <> Integer.to_string(build_id), "cmd_result", %{status: status, cmd: command})
    Logger.info " ---> Finished build " <> Integer.to_string(build_id) <> " cmd: " <> inspect(command) <> " result: " <> Integer.to_string(status)
    {:ok, status}
  end
end
