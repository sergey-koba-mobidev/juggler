defmodule Juggler.Project do
  use Juggler.Web, :model

  schema "projects" do
    field :name, :string
    field :build_commands, :string
    field :env_vars, :string
    field :docker_image, :string
    belongs_to :user, Juggler.User
    has_many :builds, Juggler.Build
    has_many :ssh_keys, Juggler.SSHKey
    has_many :integrations, Juggler.Integration

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :build_commands, :env_vars, :docker_image, :user_id])
    |> validate_required([:name, :user_id])
  end
end
