defmodule Juggler.DeployOutput do
  use Juggler.Web, :model

  schema "deploy_outputs" do
    field :event, :string
    field :payload, :map
    belongs_to :deploy, Juggler.Deploy

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:event, :payload, :deploy_id])
    |> validate_required([:event, :payload, :deploy_id])
  end
end
