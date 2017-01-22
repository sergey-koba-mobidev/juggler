defmodule Juggler.Project do
  use Juggler.Web, :model

  schema "projects" do
    field :name, :string
    field :build_commands, :string

    has_many :builds, Juggler.Build
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :build_commands])
    |> validate_required([:name])
  end
end
