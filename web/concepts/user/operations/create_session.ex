defmodule Juggler.User.Operations.CreateSession do
  import Monad.Result, only: [success: 1,
                              error: 1]

  def call(conn, user) do
    conn = Plug.Conn.put_session(conn, :current_user, user.id)
    success(conn)
  end
end
