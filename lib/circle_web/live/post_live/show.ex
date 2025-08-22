defmodule CircleWeb.PostLive.Show do
  use CircleWeb, :live_view

  alias Circle.Feed

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Post {@post.id}
        <:subtitle>This is a post record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/posts"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <%= if Circle.Accounts.Scope.can?(@current_scope, :edit, @post) do %>
            <.button
              class="btn btn-primary btn-ghost"
              navigate={~p"/posts/#{@post}/edit?return_to=show"}
            >
              <.icon name="hero-pencil-square" /> Edit post
            </.button>
          <% end %>
          <%= if Circle.Accounts.Scope.can?(@current_scope, :delete, @post) do %>
            <.button
              class="btn btn-error btn-ghost"
              phx-click={JS.push("delete", value: %{id: @post.id}) |> hide("##{@post.id}")}
              data-confirm="Are you sure?"
            >
              <.icon name="hero-trash" /> Delete
            </.button>
          <% end %>
        </:actions>
      </.header>

      <.list>
        <:item title="Content">{@post.content}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Feed.subscribe_posts(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Post")
     |> assign(:post, Feed.get_post!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %Circle.Feed.Post{id: id} = post},
        %{assigns: %{post: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :post, post)}
  end

  def handle_info(
        {:deleted, %Circle.Feed.Post{id: id}} = info,
        socket
      ) do
    Logger.info("Post #{id} deleted")
    handle_deleted(info, socket)
  end

  def handle_info({type, %Circle.Feed.Post{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end

  def handle_deleted(
        {:deleted, %Circle.Feed.Post{id: id}},
        %{assigns: %{post: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current post was deleted.")
     |> push_navigate(to: ~p"/posts")}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    post = Feed.get_post!(socket.assigns.current_scope, id)
    {:ok, _} = Feed.delete_post(socket.assigns.current_scope, post)

    {:noreply, socket}
  end
end
