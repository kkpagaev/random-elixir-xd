defmodule ShopWeb.DemoLive do
  use ShopWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :brightness, 10)}
  end

  def render(assigns) do
    ~H"""
    <h1 class="text-3xl">
      Demo
    </h1>
    """
  end
end
