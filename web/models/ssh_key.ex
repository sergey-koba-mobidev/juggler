defmodule Juggler.SSHKey do
  use Juggler.Web, :model

  schema "ssh_keys" do
    field :name, :string
    field :data, :string
    belongs_to :project, Juggler.Project

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :data, :project_id])
    |> validate_required([:name, :data])
  end
end
