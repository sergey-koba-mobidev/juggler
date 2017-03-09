defmodule Juggler.Subscription do
  use Juggler.Web, :model

  schema "subscriptions" do
    field :plan, :string
    field :state, :string
    belongs_to :user, Juggler.User

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:plan, :state, :user_id])
    |> validate_required([:plan, :state, :user_id])
  end
end
