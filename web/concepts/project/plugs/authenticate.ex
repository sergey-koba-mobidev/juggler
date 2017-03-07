defmodule Juggler.Project.Plugs.Authenticate do
  alias Juggler.{Repo, Project}
  alias Juggler.Role.Operations.CheckProjectPermission
  import Plug.Conn
  import Juggler.Router.Helpers
  import Juggler.User.Helpers
  import Juggler.Role.Helpers
  require Logger

  def init(options) do
    options
  end

  def call(conn, _) do
    not_logged_in_url = user_path(conn, :login)
    case conn.params do
      %{"project_id" => id} ->
        project = Project |> Repo.get!(id)
        if CheckProjectPermission.call(project, current_user(conn), controller_to_string(conn.private.phoenix_controller), Atom.to_string(conn.private.phoenix_action)) do
          conn
        else
          conn |> Phoenix.Controller.put_flash(:info, "You can't access that page") |> Phoenix.Controller.redirect(to: project_path(conn, :index)) |> halt
        end
      _ ->
        conn
    end
  end

end
