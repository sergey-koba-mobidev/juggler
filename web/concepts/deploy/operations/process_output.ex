defmodule Juggler.Deploy.Operations.ProcessOutput do
  alias Juggler.{Repo, DeployOutput}
  require Logger
  import Monad.Result, only: [success?: 1,
                              unwrap!: 1,
                              success: 1,
                              error: 1]

  def call(deploy, event, payload) do
    changeset = DeployOutput.changeset(%DeployOutput{}, %{
      :deploy_id => deploy.id,
      :event => event,
      :payload => payload
    })

    case Repo.insert(changeset) do
      {:ok, deploy_output} ->
        Juggler.Endpoint.broadcast("deploy:" <> Integer.to_string(deploy.id), event, payload)
        success(deploy_output)
      {:error, _changeset} ->
        Logger.error "Error inserting DeployOutput for deploy " <> Integer.to_string(deploy.id)
        error("Error inserting DeployOutput for deploy " <> Integer.to_string(deploy.id))
    end
  end

end
