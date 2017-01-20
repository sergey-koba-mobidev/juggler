defmodule Juggler.PageController do
  use Juggler.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
