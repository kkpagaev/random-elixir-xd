defmodule Shop.CatalogFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Shop.Catalog` context.
  """

  @doc """
  Generate a product.
  """
  def product_fixture(attrs \\ %{}) do
    {:ok, product} =
      attrs
      |> Enum.into(%{
        description: "some description",
        price: 42,
        title: "some title"
      })
      |> Shop.Catalog.create_product()

    product
  end
end
