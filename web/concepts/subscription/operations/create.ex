defmodule Juggler.Subscription.Operations.Create do
  import Monad.Result, only: [success: 1,
                              error: 1]
  alias Juggler.Subscription

  def call(subscription_params) do
    changeset = Subscription.changeset(%Subscription{}, subscription_params)

    case Juggler.Repo.insert(changeset) do
      {:ok, subscription} ->
        success(subscription)
      {:error, changeset} ->
        error(changeset)
    end
  end
end
