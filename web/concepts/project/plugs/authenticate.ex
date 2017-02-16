defmodule Juggler.Project.Plugs.Authenticate do
  import Plug.Conn
  import Juggler.Router.Helpers
  import Juggler.UserHelpers

  def init(options) do
    options
  end

  def call(conn, _) do
    not_logged_in_url = user_path(conn, :login)
    case conn.params do
      %{"project_id" => id} ->
        project = Project |> Repo.get!(id)
        if project.user_id == current_user(conn).id do
          conn
        else
          conn |> Phoenix.Controller.put_flash(:info, "You can't access that page") |> Phoenix.Controller.redirect(to: not_logged_in_url) |> halt
        end
      _ ->
        conn
    end
  end

end
