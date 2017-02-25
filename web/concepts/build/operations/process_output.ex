defmodule Juggler.Build.Operations.ProcessOutput do
  alias Juggler.{Repo, BuildOutput}
  require Logger
  import Monad.Result, only: [success?: 1,
                              unwrap!: 1,
                              success: 1,
                              error: 1]

  def call(build, event, payload) do
    changeset = BuildOutput.changeset(%BuildOutput{}, %{
      :build_id => build.id,
      :event => event,
      :payload => payload
    })

    case Repo.insert(changeset) do
      {:ok, build_output} ->
        Juggler.Endpoint.broadcast("build:" <> Integer.to_string(build.id), event, payload)
        success(build_output)
      {:error, _changeset} ->
        Logger.error "Error inserting BuildOutput for build " <> Integer.to_string(build.id)
        error("Error inserting BuildOutput for build " <> Integer.to_string(build.id))
    end
  end

end
