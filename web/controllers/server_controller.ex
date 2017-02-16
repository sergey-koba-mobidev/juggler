defmodule Juggler.ServerController do
  use Juggler.Web, :controller

  alias Juggler.Project
  alias Juggler.Server

  plug Juggler.Plugs.Authenticated
  plug Juggler.Project.Plugs.Authenticate

  def new(conn, _params) do
    changeset = Server.changeset(%Server{})
    render(conn, "new.html", changeset: changeset)
  end
end
