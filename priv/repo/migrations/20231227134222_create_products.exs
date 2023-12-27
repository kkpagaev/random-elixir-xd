defmodule Shop.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :title, :string, null: false
      add :slug, :string, null: false
      add :price, :decimal, precision: 15, scale: 6, null: false, default: 0
      add :description, :text, null: true

      timestamps(type: :utc_datetime)
    end
  end
end
