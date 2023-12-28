defmodule ShopWeb.Message do
  defstruct id: "", message: ""
end
defmodule ShopWeb.ChatLive do
  alias Shop.Accounts
  use ShopWeb, :live_view

  def mount(_params, _session, socket) do
    %{current_user: user} = socket.assigns

    form =
      %{message: ""}
      |> to_form(as: "message")

    socket
    |> assign(:chat_id, nil)
    |> assign(:form, form)
    |> load_chat(nil)
    |> stream(:chats, Accounts.list_chats(user))
    |> stream(:messages, [])
    |> ok()
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

  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("save", %{"message" => message}, socket) do
    %{chat_id: chat_id} = socket.assigns
    Phoenix.PubSub.broadcast(Shop.PubSub, chat_id, {:new_message, %ShopWeb.Message{ id: Ecto.UUID.generate(), message: message }})
    {:noreply, socket}
  end

  def handle_event("change-chat", %{"id" => id}, socket) do
    %{current_user: user, chat_id: old_chat_id} = socket.assigns
    chat_id = get_chat_id([user.id |> to_string, id |> to_string]) |> IO.inspect()
    if old_chat_id, do: Phoenix.PubSub.unsubscribe(Shop.PubSub, old_chat_id)
    Phoenix.PubSub.subscribe(Shop.PubSub, chat_id)

    socket
    |> load_chat(id)
    |> assign(:chat_id, chat_id)
    |> stream(:messages, [], reset: true)
    |> noreply()
  end

  defp get_chat_id(user_idx) do
    "chat:#{user_idx |> Enum.sort() |> Enum.join(":")}"
  end

  def handle_info({:new_message, message}, socket) do
    socket
    |> stream_insert(:messages, message, at: 0)
    |> noreply()
  end

  def render(assigns) do
    ~H"""
    <div class="h-screen grid grid-cols-3">
      <div class="w-full bg-gray-100">
        <div class="text-xl p-8 text-center border-b-1 border-gray-200">
          Chats
        </div>
        <div id="chats" phx-update="stream">
          <button
            :for={{dom_id, user} <- @streams.chats}
            id={dom_id}
            phx-click="change-chat"
            phx-value-id={user.id}
            class="w-full"
          >
            <div class="p-10 text-xl hover:bg-blue-200">
              <%= user.email %>
            </div>
          </button>
        </div>
      </div>
      <div class="col-span-2 w-full bg-blue-50">
        <%= if @chat do %>
          <div class="p-10 border-b-1 border-gray-200">
            <%= @chat.email %>
            <div phx-update="stream" id="messages">
              <div :for={{dom_id, message} <- @streams.messages} id={dom_id}>
                <%= message.message %>
              </div>
              <.simple_form :let={f} for={@form} phx-submit="save" phx-change="validate">
                <.input field={f[:message]} type="text" label="Message" />
                <.button type="submit" phx-disable-with="Saving...">Submit</.button>
              </.simple_form>
            </div>
          </div>
        <% else %>
          Select a chat
        <% end %>
      </div>
    </div>
    """
  end
end
