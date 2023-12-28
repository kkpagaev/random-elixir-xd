defmodule Shop.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :caption, :string
    field :image_path, :string
    field :alt, :string
    belongs_to :user, Shop.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:alt, :caption, :image_path, :user_id])
    |> validate_required([:alt, :caption, :image_path, :user_id])
  end
end
