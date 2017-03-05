defmodule Juggler.CollaboratorController do
  use Juggler.Web, :controller

  alias Juggler.Collaborator.Operations.AddCollaborator
  alias Juggler.{Project, User, ProjectUser}

  plug Juggler.Plugs.Authenticated
  plug Juggler.Project.Plugs.Authenticate

  def index(conn, %{"project_id" => project_id}) do
    collaborators = from(p in ProjectUser,
      where: p.role != "owner",
      where: p.project_id == ^project_id,
      join: u in User, on: u.id == p.user_id,
      select: {map(p, [:id, :role]), map(u, [:name, :email])}) |> Repo.all
    render conn, "index.json", collaborators: collaborators
  end

  def create(conn, %{"project_id" => project_id, "collaborator" => collaborator_params}) do
    result = AddCollaborator.call(Map.merge(collaborator_params, %{"project_id" => project_id}))

    if success?(result) do
      project_user = result.value
      collaborator = from(p in ProjectUser,
        where: p.id == ^project_user.id,
        join: u in User, on: u.id == p.user_id,
        select: {map(p, [:id, :role]), map(u, [:name, :email])}) |> Repo.one!
      conn
      |> put_status(:created)
      |> render("show.json", collaborator: collaborator)
    else
      conn
      |> put_status(:unprocessable_entity)
      |> render(Juggler.ChangesetView, "error.json", changeset: result.error)
    end
  end

  def delete(conn, %{"id" => id}) do
    ssh_key = Repo.get!(ProjectUser, id)
    Repo.delete!(ssh_key)

    send_resp(conn, :no_content, "")
  end
end
