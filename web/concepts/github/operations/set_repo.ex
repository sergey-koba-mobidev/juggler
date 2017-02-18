defmodule Juggler.GitHub.Operations.SetRepo do
  alias Juggler.GitHub.Operations.GetRepo
  alias Juggler.Integration
  alias Juggler.Repo
  use Monad.Operators
  import Monad.Result, only: [success?: 1,
                              unwrap!: 1,
                              success: 1,
                              error: 1]

  def call(owner, repo, integration) do
    result = success(nil)
              ~>> fn _ -> GetRepo.call(owner, repo, integration.data["access_token"]) end
              ~>> fn repo -> save_repo(repo, integration) end
  end

  def save_repo(repo, integration) do
    changeset = Integration.changeset(integration, %{
      :data =>  Map.merge(integration.data, %{repo: repo}),
      :state => "integrated"
    })

    case Repo.update(changeset) do
      {:ok, integration} ->
        success(integration)
      {:error, _changeset} ->
        error("Unable to set repo for Integration")
    end
  end

end
