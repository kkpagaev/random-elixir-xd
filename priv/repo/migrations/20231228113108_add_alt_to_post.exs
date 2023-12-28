defmodule Shop.Repo.Migrations.AddAltToPost do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :alt, :string
    end
  end
end
