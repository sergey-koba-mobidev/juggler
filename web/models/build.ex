defmodule Juggler.Build do
  use Juggler.Web, :model

  schema "builds" do
    field :key, :string
    field :state, :string
    field :commands, :string
    field :container_id, :string
    field :output, :string
    belongs_to :project, Juggler.Project
    has_many :build_outputs, Juggler.BuildOutput

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:key, :output, :commands, :container_id, :project_id, :state])
    |> validate_required([:key, :state, :project_id])
  end
end
