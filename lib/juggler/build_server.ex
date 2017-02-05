defmodule Juggler.BuildServer do
  use GenServer
  alias Juggler.Repo
  alias Juggler.Build
  alias Juggler.BuildOutput
  # alias Porcelain.Process, as: Proc
  alias Porcelain.Result
  require Logger

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def new_build(build_id) do
    GenServer.cast(:build_server, {:new_build, build_id})
  end

  def handle_cast({:new_build, build_id}, state) do
    build = Build |> Repo.get!(build_id)
    commands_arr = String.split(build.commands, "\n")
    update_build_state(build, "running")
    Logger.info " ---> Started build " <> Integer.to_string(build_id) <> " commands: " <> inspect(commands_arr)
    spawn fn -> exec_commands(build, commands_arr) end
    {:noreply, [build_id | state]}
  end

  def exec_commands(build, commands) do
    case List.pop_at(commands, 0) do
      {nil, []} ->
        process_build_output(build, "cmd_finished", %{})
        update_build_state(build, "finished")
      {cmd, cmds} ->
        {:ok, status} = exec_command(build, String.trim(cmd, "\r"))
        case status == 0 do
          true  -> exec_commands(build, cmds)
          false ->
            process_build_output(build, "cmd_finished_error", %{})
            update_build_state(build, "error")
        end
    end
  end

  def exec_command(build, command) do
    Logger.info " ---> Executing build " <> Integer.to_string(build.id) <> " cmd: " <> inspect(command)
    process_build_output(build, "cmd_start", %{cmd: command})
    # TODO: refactor to streams
    %Result{out: output, status: status} = Porcelain.shell(command, err: :out)
    process_build_output(build, "cmd_data", %{output: output, cmd: command})
    process_build_output(build, "cmd_result", %{status: status, cmd: command})
    Logger.info " ---> Finished build " <> Integer.to_string(build.id) <> " cmd: " <> inspect(command) <> " result: " <> Integer.to_string(status)
    {:ok, status}
  end

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
