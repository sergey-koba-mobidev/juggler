defmodule Juggler.Role.Helpers do
  def controller_to_string(controller) do
    controller
    |> Atom.to_string
    |> String.replace("Elixir.Juggler.", "")
    |> Mix.Utils.underscore
    |> String.replace("_controller", "")
  end
end
