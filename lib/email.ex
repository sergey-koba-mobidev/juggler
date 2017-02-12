defmodule Juggler.Email do
  use Bamboo.Phoenix, view: Juggler.EmailView

  def reset_password_email(conn, user) do
    new_email()
    |> to(user.email)
    |> from(System.get_env("SMTP_FROM"))
    |> subject("Reset Password on Juggler")
    |> put_html_layout({Juggler.LayoutView, "email.html"})
    |> render("reset_password.html", conn: conn, user: user)
  end
end
