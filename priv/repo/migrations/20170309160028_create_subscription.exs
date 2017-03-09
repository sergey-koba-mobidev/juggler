defmodule Juggler.Repo.Migrations.CreateSubscription do
  use Ecto.Migration

  def change do
    create table(:subscriptions) do
      add :plan, :string
      add :state, :string
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end
    create index(:subscriptions, [:user_id])

  end
end
