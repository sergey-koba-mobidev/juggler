defmodule Juggler.User.Operations.SetResetPasswordToken do
  import Monad.Result, only: [success: 1,
                              error: 1]
  alias Juggler.User
  alias Juggler.Repo

  def call(user) do
    changeset = User.changeset(user, %{"reset_password_token" => generate_token})

    case Repo.update(changeset) do
      {:ok, user} ->
        success(user)
      {:error, _changeset} ->
        error("Can't set password reset token")
    end
  end

  def generate_token do
    :crypto.strong_rand_bytes(64) |> Base.url_encode64 |> binary_part(0, 64)
  end
end
