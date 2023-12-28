defmodule ShopWeb.ChatComponent do
  use ShopWeb, :live_component

  def mount(socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="p-10 border-b-1 border-gray-200">
      <%= @user.email %>
    </div>
    """
  end
end

defmodule ShopWeb.ChatLive do
  alias Shop.Accounts
  use ShopWeb, :live_view

  def mount(_params, _session, socket) do
    socket
    |> ok()
  end

  def handle_params(params, _session, socket) do
    %{current_user: user} = socket.assigns

    socket
    |> load_chat(params["id"])
    |> stream(:chats, Accounts.list_chats(user))
    |> noreply()
  end

  defp load_chat(socket, nil), do: socket |> assign(:chat, nil)

  defp load_chat(socket, user_id) do
    socket
    |> assign(:chat, Accounts.get_user!(user_id))
  end

  def handle_event("close", _params, socket) do
    socket
    |> assign(:chat, nil)
    |> noreply()
  end

  def render(assigns) do
    ~H"""
    <div class="h-screen grid grid-cols-3">
      <div class="w-full bg-gray-100">
        <div class="text-xl p-8 text-center border-b-1 border-gray-200">
          Chats
        </div>
        <div :for={{dom_id, user} <- @streams.chats} id={dom_id} class="border-b-1 border-gray-200">
          <.link patch={~p"/chat?id=#{user.id}"}>
            <div class="p-10 text-xl hover:bg-blue-200">
              <%= user.email %>
            </div>
          </.link>
        </div>
      </div>
      <div class="col-span-2 w-full bg-blue-50">
        <%= if @chat do %>
          <.live_component module={ShopWeb.ChatComponent} id="chat" user={@chat} />
        <% else %>
          Select a chat
        <% end %>
      </div>
    </div>
    """
  end
end
