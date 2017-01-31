defmodule Juggler.User do
  use Juggler.Web, :model

  schema "users" do
    field :name, :string
    field :email, :string
    field :encrypted_password, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :email, :encrypted_password])
    |> validate_required([:name, :email, :encrypted_password])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
  end
end
