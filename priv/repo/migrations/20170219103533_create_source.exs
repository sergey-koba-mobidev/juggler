defmodule Juggler.Repo.Migrations.CreateSource do
  use Ecto.Migration

  def change do
    create table(:sources) do
      add :key, :string
      add :data, :map
      add :project_id, references(:projects, on_delete: :delete_all)

      timestamps()
    end
    create index(:sources, [:project_id])

  end
end
