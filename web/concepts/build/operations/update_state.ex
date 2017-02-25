defmodule Juggler.Build.Operations.UpdateState do
  alias Juggler.{Repo, Build}
  require Logger
  import Monad.Result, only: [success?: 1,
                              unwrap!: 1,
                              success: 1,
                              error: 1]

  def call(build, new_state) do
    changeset = Build.changeset(build, %{:state => new_state})

    case Repo.update(changeset) do
      {:ok, build} ->
        Logger.info " ---> New build " <> Integer.to_string(build.id) <> " state: " <> new_state
        success(build)
      {:error, _changeset} ->
        Logger.error "Error updating build " <> Integer.to_string(build.id) <> " state to " <> new_state
        error("Error updating build " <> Integer.to_string(build.id) <> " state to " <> new_state)
    end
  end

end
