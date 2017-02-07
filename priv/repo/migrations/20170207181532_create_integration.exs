defmodule Juggler.Repo.Migrations.CreateIntegration do
  use Ecto.Migration

  def change do
    create table(:integrations) do
      add :key, :string
      add :data, :map
      add :project_id, references(:projects, on_delete: :delete_all)

      timestamps()
    end
    create index(:integrations, [:project_id])

  end
end
