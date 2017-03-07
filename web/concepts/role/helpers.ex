defmodule Juggler.Role.Helpers do
  alias Juggler.Role.Operations.CheckProjectPermission

  def allowed?(action, controller, project, user) do
      CheckProjectPermission.call(project, user, controller, action)
  end

  def controller_to_string(controller) do
    controller
    |> Atom.to_string
    |> String.replace("Elixir.Juggler.", "")
    |> Mix.Utils.underscore
    |> String.replace("_controller", "")
  end
end
