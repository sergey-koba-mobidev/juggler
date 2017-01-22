defmodule Juggler.Build do
  use Juggler.Web, :model

  schema "builds" do
    field :key, :string
    field :state, :string
    field :output, :string
    belongs_to :project, Juggler.Project

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:key, :output, :project_id, :state])
    |> validate_required([:key, :state])
  end
end
