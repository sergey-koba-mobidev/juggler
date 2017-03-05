defmodule Juggler.CollaboratorView do
  use Juggler.Web, :view
  require Logger

  def render("index.json", %{collaborators: collaborators}) do
    %{
      collaborators: Enum.map(collaborators, &collaborator_json/1)
    }
  end

  def render("show.json", %{collaborator: collaborator}) do
    %{
      collaborator: collaborator_json(collaborator)
    }
  end

  def collaborator_json(collaborator) do
    { project_user, user } = collaborator
    %{
      id: project_user.id,
      name: user.name,
      email: user.email,
      role: project_user.role
    }
  end
end
