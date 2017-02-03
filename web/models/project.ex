defmodule Juggler.Project do
  use Juggler.Web, :model

  schema "projects" do
    field :name, :string
    field :build_commands, :string
    belongs_to :user, Juggler.User
    has_many :builds, Juggler.Build

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :build_commands, :user_id])
    |> validate_required([:name, :user_id])
  end
end
