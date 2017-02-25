defmodule Juggler.Deploy do
  use Juggler.Web, :model

  schema "deploys" do
    field :key, :string
    field :state, :string
    field :commands, :string
    belongs_to :user, Juggler.User
    belongs_to :build, Juggler.Build
    belongs_to :server, Juggler.Server
    belongs_to :project, Juggler.Project

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:key, :state, :commands, :build_id, :server_id, :project_id, :user_id])
    |> validate_required([:key, :state, :commands, :build_id, :server_id, :project_id])
  end
end
