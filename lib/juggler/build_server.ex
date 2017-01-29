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
    exec_commands(build.id, build.project.build_commands)
    {:noreply, [build_id | state]}
  end

  def exec_commands(build_id, commands) do
    commands_arr = String.split(commands, "\n")
    for command <- commands_arr do
      {:ok, status} = exec_command(build_id, String.trim(command, "\r"))
    end
  end

  def exec_command(build_id, command) do
    Logger.info "Executing build " <> Integer.to_string(build_id) <> " cmd: " <> inspect(command)
    Juggler.Endpoint.broadcast("build:" <> Integer.to_string(build_id), "cmd_start", %{cmd: command})
    %Result{out: output, status: status} = Porcelain.shell(command)
    Juggler.Endpoint.broadcast("build:" <> Integer.to_string(build_id), "cmd_data", %{output: output, cmd: command})
    Juggler.Endpoint.broadcast("build:" <> Integer.to_string(build_id), "cmd_result", %{status: status, cmd: command})
    Logger.info "Finished build " <> Integer.to_string(build_id) <> " cmd: " <> inspect(command) <> " result: " <> Integer.to_string(status)
    {:ok, status}
  end
end
