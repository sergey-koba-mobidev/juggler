defmodule Juggler.Repo.Migrations.CreateDeployOutput do
  use Ecto.Migration

  def change do
    create table(:deploy_outputs) do
      add :event, :string
      add :payload, :map
      add :deploy_id, references(:deploys, on_delete: :delete_all)

      timestamps()
    end
    create index(:deploy_outputs, [:deploy_id])

  end
end
