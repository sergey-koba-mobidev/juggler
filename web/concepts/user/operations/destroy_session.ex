defmodule Juggler.User.Operations.DestroySession do
  import Monad.Result, only: [success: 1,
                              error: 1]
  import Plug.Conn

  def call(conn) do
    conn = conn
          |> delete_session(:current_user)
          |> assign(:current_user, nil)
    success(conn)
  end
end
