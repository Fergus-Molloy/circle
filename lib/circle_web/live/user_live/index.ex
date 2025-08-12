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
        <:col :let={{_id, user}} label="User names">{user.username}</:col>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Listing Users")
     |> stream(:users, Accounts.list_users(socket.assigns.current_scope))}
  end
end
