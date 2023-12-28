defmodule ShopWeb.HomeLive do
  use ShopWeb, :live_view
  alias Shop.Posts.Post
  alias Shop.Posts

  def mount(_params, _session, socket) do
    # unless connected?(socket) do
    #   socket
    #   |> assign(:loading, true)
    #   |> ok()
    # else
    Phoenix.PubSub.subscribe(Shop.PubSub, "posts")

    form =
      %Post{}
      |> Post.changeset(%{})
      |> to_form(as: "post")

    socket
    |> assign(:loading, false)
    |> assign(:form, form)
    |> allow_upload(:image, accept: ~w(.jpg .jpeg .png), max_entries: 1)
    |> stream(:posts, Posts.list_posts())
    |> ok()

    # end
  end

  def render(%{loading: true} = assigns) do
    ~H"""
    Loading...
    """
  end

  def render(assigns) do
    ~H"""
    <h1>Home</h1>
    <.modal id="new-post-modal">
      <h2>New Post</h2>
      <.simple_form :let={f} for={@form} phx-change="validate" phx-submit="save">
        <.input field={f[:caption]} type="textarea" label="Caption" />
        <.input field={f[:alt]} type="text" label="Alt" />
        <.live_file_input upload={@uploads.image} required />
        <.button type="submit" phx-disable-with="Saving...">Submit</.button>
      </.simple_form>
    </.modal>
    <div id="feed" phx-update="stream">
      <div :for={{dom_id, post} <- @streams.posts} id={dom_id}>
        <img src={post.image_path} />
        <p><%= post.caption %></p>
        <p><%= post.user.email %></p>
      </div>
    </div>
    """
  end

  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("save", post_params, socket) do
    %{current_user: user} = socket.assigns

    post_params
    |> Map.put("user_id", user.id)
    |> Map.put("image_path", List.first(consume_files(socket)))
    |> Posts.save()
    |> case do
      {:ok, post} ->
        socket =
          socket
          |> put_flash(:info, "Post created")
          |> push_navigate(to: ~p"/")
          |> noreply()

        Phoenix.PubSub.broadcast(Shop.PubSub, "posts", {:new_post, Map.put(post, :user, user)})

        socket

      {:error, changeset} ->
        socket
        |> assign(:form, to_form(changeset, as: "post"))
        |> put_flash(:error, "Failed to create post")
        |> noreply()
    end
  end

  defp consume_files(socket) do
    consume_uploaded_entries(socket, :image, fn %{path: path}, _entry ->
      IO.inspect(path)
      dest = Path.join([:code.priv_dir(:shop), "static", "uploads", Path.basename(path)])
      File.cp!(path, dest)

      {:postpone, ~p"/uploads/#{Path.basename(dest)}"}
    end)
  end

  def error_to_string(:too_large), do: "Too large"
  def error_to_string(:not_accepted), do: "You have selected an unacceptable file type"

  def handle_info({:new_post, post}, socket) do
    socket
    |> put_flash(:info, "New post from #{post.user.email}")
    |> stream_insert(:posts, post, at: 0)
    |> noreply()
  end
end
