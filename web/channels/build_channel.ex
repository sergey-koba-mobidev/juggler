defmodule Juggler.BuildChannel do
  use Phoenix.Channel

  def join("build:" <> build_id, _params, socket) do
    {:ok, socket}
  end
end
