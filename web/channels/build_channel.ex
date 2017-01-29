defmodule Juggler.BuildChannel do
  use Phoenix.Channel
  alias Juggler.Repo
  alias Juggler.Build
  import Ecto
  import Ecto.Query
  require Logger

  def join("build:" <> build_id, params, socket) do
    send(self, {:after_join, params})
    {:ok, assign(socket, :build_id, build_id)}
  end

  def handle_info({:after_join, params}, socket) do
    build = Repo.get(Build, socket.assigns.build_id)
    #outputs = Repo.all(assoc(build, :build_outputs))
    outputs = Repo.all(
      from o in assoc(build, :build_outputs),
        select: %{id: o.id, event: o.event, payload: o.payload}
    )
    Logger.info "----- OUTPUTS!!! " <> inspect(outputs)
    push socket, "cmd_old", %{outputs: outputs}
    {:noreply, socket}
  end
end
