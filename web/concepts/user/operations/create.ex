defmodule Juggler.User.Operations.Create do
  import Monad.Result, only: [success: 1,
                              error: 1]
  alias Juggler.User

  def call(user_params) do
    changeset = User.changeset(%User{}, user_params)

    case Juggler.Repo.insert(changeset) do
      {:ok, user} ->
        success(user)
      {:error, changeset} ->
        error(changeset)
    end
  end
end
