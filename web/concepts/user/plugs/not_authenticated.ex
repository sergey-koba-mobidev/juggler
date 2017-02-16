defmodule Juggler.Plugs.NotAuthenticated do
  import Plug.Conn
  import Juggler.Router.Helpers

  def init(options) do
    options
  end

  def call(conn, _) do
    conn = fetch_session(conn)
    if is_logged_in(get_session(conn, :current_user)) do
      conn |> Phoenix.Controller.put_flash(:info, "You should logout first")  |> Phoenix.Controller.redirect(to: "/") |> halt
    else
      conn
    end
  end

  def is_logged_in(user_session) do
    case user_session do
      nil -> false
      _   -> true
    end
  end

end
