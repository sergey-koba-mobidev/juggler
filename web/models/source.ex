defmodule Juggler.Source do
  use Juggler.Web, :model

  schema "sources" do
    field :key, :string
    field :data, :map
    belongs_to :project, Juggler.Project

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:key, :data, :project_id])
    |> validate_required([:key, :data, :project_id])
  end
end
