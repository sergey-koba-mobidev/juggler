defmodule Juggler.Repo.Migrations.CreateProject do
  use Ecto.Migration

  def change do
    create table(:projects) do
      add :name, :string
      add :build_commands, :string

      timestamps()
    end

  end
end
