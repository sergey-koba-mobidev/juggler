defmodule Juggler.LayoutView do
  use Juggler.Web, :view

  def page_active_class(conn, page) do
    current_path = Path.join(["/" | conn.path_info])
    if current_path == page do
      "active"
    else
      nil
    end
  end

  def projects_active_class(conn) do
    current_path = Path.join(["/" | conn.path_info])
    if Regex.match?(~r/projects/, current_path) do
      "active"
    else
      nil
    end
  end
end
