defmodule Juggler.User.Operations.SendResetPasswordEmail do
  import Monad.Result, only: [success: 1,
                              error: 1]
  alias Juggler.User
  alias Juggler.Repo

  def call(conn, user) do
    Juggler.Email.reset_password_email(conn, user) |> Juggler.Mailer.deliver_later
    success(user)
  end
end
