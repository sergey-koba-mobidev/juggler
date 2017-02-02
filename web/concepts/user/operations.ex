defmodule Juggler.UserOperations do
  alias Juggler.Repo
  alias Juggler.User
  import Ecto
  import Ecto.Query
  import Monad.Result, only: [success?: 1,
                              unwrap!: 1,
                              success: 1,
                              error: 1]


  def validate_user_exists(email) do
    case Repo.get_by(User, email: email) do
      nil  -> error("Incorrect e-mail/password")
      user -> success(user)
    end
  end
  def validate_password(user, password) do
    success(nil)
  end
end
