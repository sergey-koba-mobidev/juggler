defmodule Juggler.User.Operations.GetByResetPasswordToken do
  import Monad.Result, only: [success: 1,
                              error: 1]

  def call(email, token) do
    case Juggler.Repo.get_by(Juggler.User, email: email, reset_password_token: token) do
      nil  -> error("User not found")
      user -> success(user)
    end
  end
end
