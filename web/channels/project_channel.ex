defmodule Juggler.ProjectChannel do
  use Phoenix.Channel

  def join("project:" <> project_id, params, socket) do
    send(self(), {:after_join, params})
    {:ok, assign(socket, :project_id, project_id)}
  end
end
