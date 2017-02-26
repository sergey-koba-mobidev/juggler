defmodule Juggler.DeployView do
  use Juggler.Web, :view
  use Timex
  alias Juggler.{User, Repo, Server}
  import Kerosene.HTML
  import Exgravatar

  def icon(deploy) do
    case deploy.state do
          "finished" -> raw("<i class='checkmark green icon'></i>")
          "error"    -> raw("<i class='remove red icon'></i>")
          "running"  -> raw("<i class='refresh loading blue icon'></i>")
          "new"      -> raw("<i class='hourglass start icon'></i>")
    end
  end

  def time_ago(deploy) do
    case Timex.format(deploy.inserted_at, "{relative}", :relative) do
      {:ok, time_ago} -> time_ago
      _ -> deploy.inserted_at
    end
  end

  def avatar_url(deploy) do
    if deploy.user_id == nil do
      "/images/anonym.png"
    else
      user = User |> Repo.get!(deploy.user_id)
      gravatar_url user.email
    end
  end

  def user_name(deploy) do
    if deploy.user_id == nil do
      "Juggler"
    else
      user = User |> Repo.get!(deploy.user_id)
      user.name
    end
  end

  def server(conn, deploy) do
    server = Server |> Repo.get!(deploy.server_id)
    link server.name, to: project_server_path(conn, :show, deploy.project_id, server)
  end

  def duration(deploy) do
    dur_str = Duration.from_seconds(Timex.diff(deploy.updated_at, deploy.inserted_at, :seconds)) |> Timex.format_duration(:humanized)
    case dur_str == "" do
      true -> ""
      false -> raw("<i class='wait icon'></i>  " <> dur_str)
    end
  end
end
