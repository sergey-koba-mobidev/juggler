defmodule Juggler.Server do
  use Juggler.Web, :model

  schema "servers" do
    field :name, :string
    field :deploy_commands, :string
    belongs_to :project, Juggler.Project

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :deploy_commands, :project_id])
    |> validate_required([:name, :deploy_commands, :project_id])
  end

  def latest_deploy(server) do
    Juggler.Repo.one(from d in Juggler.Deploy, where: d.server_id == ^server.id, order_by: [desc: d.inserted_at], limit: 1)
  end
end
