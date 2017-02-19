defmodule Juggler.Repo.Migrations.CreateBuildOutput do
  use Ecto.Migration

  def change do
    create table(:build_outputs) do
      add :event, :string
      add :payload, :map
      add :build_id, references(:builds, on_delete: :delete_all)

      timestamps()
    end
    create index(:build_outputs, [:build_id])

  end
end
