defmodule Juggler.UserOperations do
  alias Juggler.Repo
  alias Juggler.User
  import Ecto
  import Ecto.Query
  import Comeonin.Bcrypt
  import Plug.Conn
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
    case checkpw(password, user.encrypted_password) do
      false  -> error("Incorrect e-mail/password")
      true   -> success(user)
    end
  end

  def create_session(conn, user) do
    conn = put_session(conn, :current_user, user.id)
    success(conn)
  end

  def destroy_session(conn) do
    conn = conn
          |> delete_session(:current_user)
          |> assign(:current_user, nil)
    success(conn)
  end
end
