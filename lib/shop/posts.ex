defmodule Shop.Posts do
  import Ecto.Query

  alias Shop.Repo
  alias Shop.Posts.Post

  def save(post) do
    %Post{}
    |> Post.changeset(post)
    |> Repo.insert()
  end

  def list_posts() do
    query = from p in Post,
      select: p,
      order_by: [desc: p.id],
      preload: [:user]

    Repo.all(query)
  end
end
