defmodule Juggler.GitHub.Operations.CreatePushWebhook do
  alias Juggler.{Integration, Repo}
  use Monad.Operators
  import Monad.Result, only: [success?: 1,
                              unwrap!: 1,
                              success: 1,
                              error: 1]

  def call(owner, repo, integration, webhook_url) do
    result = success(nil)
              ~>> fn _ -> create_webhook(owner, repo, integration.data["access_token"], webhook_url) end
              ~>> fn webhook -> save_webhook(webhook, integration) end
  end

  def create_webhook(owner, repo, access_token, webhook_url) do
    client = Tentacat.Client.new(%{access_token: access_token})
    hook_body = %{
      "name" => "web",
      "active" => true,
      "events" => [ "push" ],
      "config" => %{
        "url" => webhook_url,
        "content_type" => "json"
      }
    }
    case Tentacat.Hooks.create(owner, repo, hook_body, client) do
      {201, webhook} -> success(webhook)
      {code, err}  -> error(err)
    end
  end

  def save_webhook(webhook, integration) do
    changeset = Integration.changeset(integration, %{
      :data =>  Map.merge(integration.data, %{webhook: webhook}),
      :state => "integrated"
    })

    case Repo.update(changeset) do
      {:ok, integration} ->
        success(integration)
      {:error, _changeset} ->
        error("Unable to set webhook for Integration")
    end
  end

end
