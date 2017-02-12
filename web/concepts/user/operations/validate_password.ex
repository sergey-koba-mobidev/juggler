defmodule Juggler.User.Operations.ValidatePassword do
  import Monad.Result, only: [success: 1,
                              error: 1]

  def call(user, password) do
    case Comeonin.Bcrypt.checkpw(password, user.encrypted_password) do
      false  -> error("User not found")
      true   -> success(user)
    end
  end
end
