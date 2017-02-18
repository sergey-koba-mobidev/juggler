defmodule Juggler.GitHub.Operations.ProcessCallback do
  alias Juggler.Repo
  alias Juggler.Project
  alias Juggler.Integration
  require Logger
  use Monad.Operators
  import Juggler.GitHub.Helpers
  import Monad.Result, only: [success?: 1,
                              unwrap!: 1,
                              success: 1,
                              error: 1]

  def call(project_id, callback_url, code) do
    result = success(nil)
              ~>> fn _ -> get_access_token(callback_url, code) end
              ~>> fn access_token -> save_access_token(project_id, access_token) end
    case success?(result) do
      true  -> success(result.value)
      false -> error(result.error)
    end
  end

  def get_access_token(callback_url, code) do
    try do
      success(GithubOauth.get_token(config(callback_url), code))
    rescue
      e -> error(inspect(e))
    end
  end

  def save_access_token(project_id, access_token) do
    integration = Repo.get_by(Integration, project_id: project_id, key: "github")
    changeset_object = nil

    case integration do
      nil -> changeset_object = %Integration{}
      integration -> changeset_object = integration
    end

    changeset = Integration.changeset(changeset_object, %{
      :project_id => project_id,
      :key => "github",
      :data => %{access_token: access_token}
    })

    case Repo.insert_or_update(changeset) do
      {:ok, integration} ->
        success(integration)
      {:error, _changeset} ->
        error("Unable to save Integration")
    end
  end
end
