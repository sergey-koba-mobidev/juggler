defmodule Juggler.Collaborator.Operations.AddCollaborator do
  alias Juggler.{Repo, ProjectUser}
  require Logger
  import Monad.Result, only: [success?: 1,
                              unwrap!: 1,
                              success: 1,
                              error: 1]

  def call(collaborator_params) do
    changeset = ProjectUser.changeset(%ProjectUser{}, collaborator_params)
    if Enum.member?(["admin", "edit"], collaborator_params["role"]) do
      case Repo.insert(changeset) do
        {:ok, collaborator} ->
          success(collaborator)
        {:error, changeset} ->
          error(changeset)
      end
    else
      error("Wrong collaborator role")
    end
  end

end
