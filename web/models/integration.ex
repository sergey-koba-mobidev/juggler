defmodule Juggler.Integration do
  use Juggler.Web, :model

  schema "integrations" do
    field :key, :string
    field :state, :string
    field :data, :map
    belongs_to :project, Juggler.Project

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:key, :data, :project_id, :state])
    |> validate_required([:key, :data, :project_id])
  end
end
