defmodule CircleWeb.PostLive.Index do
  use CircleWeb, :live_view
  import CircleWeb.Components.Post

  alias Circle.Feed
  alias Circle.Accounts.Scope

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Posts
        <:actions>
          <.button variant="primary" navigate={~p"/posts/new"}>
            <.icon name="hero-plus" /> New Post
          </.button>
        </:actions>
      </.header>
      <div class="flex flex-col divide-solid divide-y-1 divide-neutral">
        <%= for {_id, post} <- @streams.posts do %>
          <.post post={post} />
        <% end %>
      </div>

      <.table
        id="posts"
        rows={@streams.posts}
        row_click={fn {_id, post} -> JS.navigate(~p"/posts/#{post}") end}
      >
        <:col :let={{_id, post}} label="Content">{post.content}</:col>
        <:action :let={{_id, post}}>
          <div class="sr-only">
            <.link navigate={~p"/posts/#{post}"}>Show</.link>
          </div>
          <%= if Scope.can?(@current_scope, :edit, post) do %>
            <.link navigate={~p"/posts/#{post}/edit"}>Edit</.link>
          <% end %>
        </:action>
        <:action :let={{id, post}}>
          <%= if Scope.can?(@current_scope, :delete, post) do %>
            <.link
              phx-click={JS.push("delete", value: %{id: post.id}) |> hide("##{id}")}
              data-confirm="Are you sure?"
            >
              Delete
            </.link>
          <% end %>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Feed.subscribe_posts(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Posts")
     |> stream(:posts, Feed.list_posts(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    post = Feed.get_post!(socket.assigns.current_scope, id)
    {:ok, _} = Feed.delete_post(socket.assigns.current_scope, post)

    {:noreply, stream_delete(socket, :posts, post)}
  end

  @impl true
  def handle_info({:deleted, %Circle.Feed.Post{} = post}, socket) do
    {:noreply, stream_delete(socket, :posts, post)}
  end

  @impl true
  def handle_info({type, %Circle.Feed.Post{} = post}, socket)
      when type in [:created, :updated] do
    {:noreply, stream_insert(socket, :posts, post)}
  end
end
