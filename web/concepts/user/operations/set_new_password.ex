defmodule Juggler.User.Operations.SetNewPassword do
  import Monad.Result, only: [success: 1,
                              error: 1]
  alias Juggler.User
  alias Juggler.Repo

  def call(user, user_params) do
    user_params = Map.merge(user_params, %{"reset_password_token" => nil})
    changeset = User.changeset(user, user_params)

    case Repo.update(changeset) do
      {:ok, user} ->
        success(user)
      {:error, changeset} ->
        error(changeset)
    end
  end
end
