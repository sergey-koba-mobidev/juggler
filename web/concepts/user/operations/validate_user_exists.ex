defmodule Juggler.User.Operations.ValidateUserExists do
  import Monad.Result, only: [success: 1,
                              error: 1]

  def call(email) do
    case Juggler.Repo.get_by(Juggler.User, email: email) do
      nil  -> error("User not found")
      user -> success(user)
    end
  end
end
