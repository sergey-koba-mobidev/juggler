defmodule Juggler.UserHelpers do
  alias Juggler.Repo
  alias Juggler.User
  import Ecto
  import Ecto.Query

  def current_user(conn) do
    id = Plug.Conn.get_session(conn, :current_user)
    if id, do: Juggler.Repo.get(User, id)
  end

  def is_logged_in(conn) do
    current_user(conn) != nil
  end
end
