defmodule Juggler.User.Operations.EncryptPasswordParam do
  import Monad.Result, only: [success: 1,
                              error: 1]

  def call(user_params) do
    if user_params["password"] != "", do: user_params = Map.merge(user_params, %{"encrypted_password" => Comeonin.Bcrypt.hashpwsalt(user_params["password"])})
    success(user_params)
  end
end
