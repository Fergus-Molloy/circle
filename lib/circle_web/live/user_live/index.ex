defmodule CircleWeb.UserLive.Index do
  use CircleWeb, :live_view

  alias Circle.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Users
      </.header>

      <.table
        id="posts"
        rows={@streams.users}
      >
        <:col :let={{_id, user}} label="User names">
          <div class="flex gap-2 justify-between">
            <span>{user.username}</span>
            <%= if user.followed_by_current_user do %>
              <.button
                variant="error"
                phx-disable-with="Unfollowing..."
                phx-click="unfollow"
                value={user.id}
              >
                Unfollow
              </.button>
            <% else %>
              <.button
                variant="primary"
                phx-disable-with="Following..."
                phx-click="follow"
                value={user.id}
              >
                Follow
              </.button>
            <% end %>
          </div>
        </:col>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Listing Users")
     |> stream(
       :users,
       Accounts.list_possible_follows_for_user(socket.assigns.current_scope.user)
     )}
  end

  @impl true
  def handle_event("follow", %{"value" => id}, socket) do
    %{user: user} = socket.assigns.current_scope
    to_follow = Accounts.get_user!(id)

    {:ok, _} = Accounts.follow_user(user, to_follow)
    to_follow = %{to_follow | followed_by_current_user: true}
    {:noreply, socket |> stream_insert(:users, to_follow)}
  end

  @impl true
  def handle_event("unfollow", %{"value" => id}, socket) do
    %{user: user} = socket.assigns.current_scope

    to_unfollow = Accounts.get_user!(id)
    {:ok, _} = Accounts.unfollow_user(user, to_unfollow)
    to_unfollow = %{to_unfollow | followed_by_current_user: false}

    {:noreply, stream_insert(socket, :users, to_unfollow)}
  end
end
