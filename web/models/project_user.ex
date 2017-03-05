defmodule Juggler.ProjectUser do
  use Juggler.Web, :model

  schema "projects_users" do
    field :role, :string
    belongs_to :project, Juggler.Project
    belongs_to :user, Juggler.User

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:role, :user_id, :project_id])
    |> validate_required([:role, :user_id, :project_id])
    |> unique_constraint(:role, name: :projects_users_project_id_user_id_index)
  end
end
