defmodule Juggler.Repo.Migrations.CreateDeploy do
  use Ecto.Migration

  def change do
    create table(:deploys) do
      add :key, :string
      add :state, :string
      add :container_id, :string
      add :commands, :text
      add :user_id, references(:users, on_delete: :nothing)
      add :build_id, references(:builds, on_delete: :delete_all)
      add :server_id, references(:servers, on_delete: :delete_all)
      add :project_id, references(:projects, on_delete: :delete_all)

      timestamps()
    end
    create index(:deploys, [:user_id])
    create index(:deploys, [:build_id])
    create index(:deploys, [:server_id])
    create index(:deploys, [:project_id])

  end
end
