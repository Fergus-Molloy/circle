defmodule Circle.Repo.Migrations.AddUserFollowers do
  use Ecto.Migration

  def change do
    create table(:user_followers, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :follows_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:user_followers, [:user_id])
    create index(:user_followers, [:follows_id])
    create unique_index(:user_followers, [:user_id, :follows_id])
  end
end
