defmodule Juggler.GitHub.Operations.Unlink do
  alias Juggler.Integration
  alias Juggler.Repo
  import Monad.Result, only: [success?: 1,
                              unwrap!: 1,
                              success: 1,
                              error: 1]

  def call(integration) do
    changeset = Integration.changeset(integration, %{
      :state => "unlinked"
    })

    case Repo.update(changeset) do
      {:ok, integration} ->
        success(integration)
      {:error, _changeset} ->
        error("Unable to unlink GitHub")
    end
  end

end
