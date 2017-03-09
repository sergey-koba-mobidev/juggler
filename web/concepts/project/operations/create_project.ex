defmodule Juggler.Project.Operations.CreateProject do
  alias Juggler.{Repo, Project, ProjectUser}
  import Monad.Result, only: [success?: 1,
                              unwrap!: 1,
                              success: 1,
                              error: 1]

  def call(project_params) do
    changeset = Project.changeset(%Project{}, project_params)

    case Repo.insert(changeset) do
      {:ok, project} ->
        changeset_owner = ProjectUser.changeset(%ProjectUser{}, %{
          "user_id" => project_params["user_id"],
          "project_id" => project.id,
          "role" => "owner"
        })
        case Repo.insert(changeset_owner) do
          {:ok, project_user} ->
            success(project)
          {:error, changeset} ->
            error(changeset)
        end
      {:error, changeset} ->
        error(changeset)
    end
  end
end
