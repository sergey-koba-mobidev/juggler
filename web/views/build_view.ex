defmodule Juggler.BuildView do
  use Juggler.Web, :view

  def build_icon(build_state) do
    case build_state do
          "finished" -> raw("<i class='checkmark green icon'></i>")
          "error"    -> raw("<i class='remove red icon'></i>")
          "running"  -> raw("<i class='refresh blue icon'></i>")
          "new"      -> raw("<i class='hourglass start icon'></i>")
    end
  end
end
