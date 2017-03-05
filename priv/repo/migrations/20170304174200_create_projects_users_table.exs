defmodule Juggler.Repo.Migrations.CreateProjectsUsersTable do
  use Ecto.Migration

  def change do
    create table(:projects_users) do
      add :role, :string
      add :project_id, references(:projects, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end
    create unique_index(:projects_users, [:project_id, :user_id])
  end
end
