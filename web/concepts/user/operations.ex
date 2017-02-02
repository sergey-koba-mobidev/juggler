defmodule Juggler.UserOperations do
  import Monad.Result, only: [success?: 1,
                              unwrap!: 1,
                              success: 1,
                              error: 1]

  def validate_user_exists(email) do
    success(nil)
  end
  def validate_password(user, password) do
    success(nil)
  end
end
