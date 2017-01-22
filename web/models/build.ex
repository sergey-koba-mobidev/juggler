defmodule Juggler.Build do
  use Juggler.Web, :model

  schema "builds" do
    field :key, :string
    field :output, :string
    belongs_to :project, Juggler.Project

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:key, :output, :project_id])
    |> validate_required([:key])
  end
end
