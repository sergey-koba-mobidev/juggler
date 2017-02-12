defmodule Juggler.EmailView do
  use Juggler.Web, :view

  def new_password_link(conn, user) do
    user_url(conn, :new_password, email: user.email, token: user.reset_password_token)
  end
end
