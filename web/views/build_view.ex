defmodule Juggler.BuildView do
  use Juggler.Web, :view
  use Timex
  import Kerosene.HTML
  alias Juggler.{Source, Repo}

  def icon(build) do
    case build.state do
          "finished" -> raw("<i class='checkmark green icon'></i>")
          "error"    -> raw("<i class='remove red icon'></i>")
          "running"  -> raw("<i class='refresh loading blue icon'></i>")
          "new"      -> raw("<i class='hourglass start icon'></i>")
          "stopped"  -> raw("<i class='stop circle outline red icon'></i>")
    end
  end

  def time_ago(build) do
    case Timex.format(build.inserted_at, "{relative}", :relative) do
      {:ok, time_ago} -> time_ago
      _ -> build.inserted_at
    end
  end

  def avatar_url(build) do
    if build.source_id == nil do
      "/images/anonym.png"
    else
      source = Source |> Repo.get!(build.source_id)
      case source.key do
        "github" -> source.data["sender"]["avatar_url"]
        _ -> "/images/anonym.png"
      end
    end
  end

  def user_name(build) do
    if build.source_id == nil do
      "Juggler"
    else
      source = Source |> Repo.get!(build.source_id)
      case source.key do
        "github" -> source.data["sender"]["login"]
        _ -> "Juggler"
      end
    end
  end

  def code_source(build) do
    if build.source_id == nil do
      ""
    else
      source = Source |> Repo.get!(build.source_id)
      case source.key do
        "github" -> raw("<i class='github icon'></i> <a href='" <> source.data["compare"] <> "' target='_blank'>" <> String.replace(source.data["ref"], "refs/heads/", "") <> "</a>")
        _ -> ""
      end
    end
  end

  def duration(build) do
    dur_str = Duration.from_seconds(Timex.diff(build.updated_at, build.inserted_at, :seconds)) |> Timex.format_duration(:humanized)
    case dur_str == "" do
      true -> ""
      false -> raw("<i class='wait icon'></i>  " <> dur_str)
    end
  end
end
