defmodule Juggler.Repo.Migrations.CreateServer do
  use Ecto.Migration

  def change do
    create table(:servers) do
      add :name, :string
      add :deploy_commands, :text
      add :project_id, references(:projects, on_delete: :nothing)

      timestamps()
    end
    create index(:servers, [:project_id])

  end
end
