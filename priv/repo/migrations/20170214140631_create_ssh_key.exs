defmodule Juggler.Repo.Migrations.CreateSSHKey do
  use Ecto.Migration

  def change do
    create table(:ssh_keys) do
      add :name, :string
      add :data, :text
      add :project_id, references(:projects, on_delete: :delete_all)

      timestamps()
    end
    create index(:ssh_keys, [:project_id])

  end
end
