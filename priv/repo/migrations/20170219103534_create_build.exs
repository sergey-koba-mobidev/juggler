defmodule Juggler.Repo.Migrations.CreateBuild do
  use Ecto.Migration

  def change do
    create table(:builds) do
      add :key, :string
      add :state, :string
      add :commands, :string
      add :container_id, :string
      add :output, :text
      add :project_id, references(:projects, on_delete: :delete_all)
      add :source_id, references(:sources, on_delete: :nothing)

      timestamps()
    end
    create index(:builds, [:project_id])

  end
end
