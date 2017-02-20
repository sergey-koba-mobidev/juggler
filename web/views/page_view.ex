defmodule Juggler.PageView do
  use Juggler.Web, :view

  def home_active_class(conn) do
    current_path = Path.join(["/" | conn.path_info])
    if current_path == "/" do
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
