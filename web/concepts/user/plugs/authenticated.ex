defmodule Juggler.Plugs.Authenticated do
  import Plug.Conn
  import Juggler.Router.Helpers

  def init(options) do
    options
  end

  def call(conn, _) do
    conn = fetch_session(conn)
    not_logged_in_url = user_path(conn, :login)
    if is_logged_in(get_session(conn, :current_user)) do
      assign(conn, :current_user, get_session(conn, :current_user))
    else
      conn |> Phoenix.Controller.redirect(to: not_logged_in_url) |> halt
    end
  end

  def is_logged_in(user_session) do
    case user_session do
      nil -> false
      _   -> true
    end
  end

end
