defmodule Juggler.Role.Operations.CheckProjectPermission do
  alias Juggler.{Repo, ProjectUser}
  require Logger

  def call(project, user, controller, action) do
    project_user = Repo.get_by(ProjectUser, project_id: project.id, user_id: user.id)
    if project_user == nil do
      false
    else
      module = Module.concat(Juggler.Role, String.capitalize(project_user.role))
      allows = apply(module, :allow, [])
      denies = apply(module, :deny, [])
      in_list?(controller, action, allows) && !in_list?(controller, action, denies)
    end
  end

  def in_list?(controller, action, list) do
    case List.pop_at(list, 0) do
      {nil, []} ->
        false
      {item, items} ->
        case in_item?(controller, action, item) do
          true  -> true
          false -> in_list?(controller, action, items)
        end
    end
  end

  def in_item?(controller, action, item) do
    {controller_regex, action_regex} = item
    {:ok, controller_r} = Regex.compile("^" <> controller_regex <> "$")
    {:ok, action_r} = Regex.compile("^" <> action_regex <> "$")
    Regex.match?(controller_r, controller) && Regex.match?(action_r, action)
  end
end
