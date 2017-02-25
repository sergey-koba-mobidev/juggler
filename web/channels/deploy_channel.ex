defmodule Juggler.DeployChannel do
  use Phoenix.Channel
  alias Juggler.Repo
  alias Juggler.Deploy
  import Ecto
  import Ecto.Query
  require Logger

  def join("deploy:" <> deploy_id, params, socket) do
    send(self(), {:after_join, params})
    {:ok, assign(socket, :deploy_id, deploy_id)}
  end

  def handle_info({:after_join, _params}, socket) do
    deploy = Repo.get(Deploy, socket.assigns.deploy_id)
    outputs = Repo.all(
      from o in assoc(deploy, :deploy_outputs),
        select: %{id: o.id, event: o.event, payload: o.payload}
    )
    Logger.info "----- OUTPUTS!!! " <> inspect(outputs)
    push socket, "cmd_old", %{outputs: outputs}
    {:noreply, socket}
  end
end
