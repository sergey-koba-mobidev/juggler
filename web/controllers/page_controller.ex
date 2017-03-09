defmodule Juggler.PageController do
  use Juggler.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def subscription_suspended(conn, _params) do
    render conn, "subscription_suspended.html"
  end

  def plans(conn, _params) do
    render conn, "plans.html"
  end

  def about(conn, _params) do
    render conn, "about.html"
  end

  def terms(conn, _params) do
    render conn, "terms.html"
  end
end
