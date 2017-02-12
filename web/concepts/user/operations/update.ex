defmodule Juggler.User.Operations.Update do
  import Monad.Result, only: [success: 1,
                              error: 1]
  alias Juggler.User
  alias Juggler.Repo

  def call(id, user_params) do
    user = Repo.get!(User, id)
    changeset = User.changeset(user, user_params)

    case Repo.update(changeset) do
      {:ok, user} ->
        success(user)
      {:error, changeset} ->
        error(changeset)
    end
  end
end
