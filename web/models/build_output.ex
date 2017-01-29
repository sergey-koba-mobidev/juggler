defmodule Juggler.BuildOutput do
  use Juggler.Web, :model

  schema "build_outputs" do
    field :event, :string
    field :payload, :map
    belongs_to :build, Juggler.Build

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:event, :payload, :build_id])
    |> validate_required([:event, :payload, :build_id])
  end
end
