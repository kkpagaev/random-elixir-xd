defmodule Shop.Repo.Migrations.ChangePostCaptionTypo do
  use Ecto.Migration

  def change do
    rename table(:posts), :cation, to: :caption
  end
end
