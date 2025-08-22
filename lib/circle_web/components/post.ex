defmodule CircleWeb.Components.Post do
  alias Circle.Accounts
  use Phoenix.Component
  use Gettext, backend: CircleWeb.Gettext

  use Phoenix.VerifiedRoutes,
    endpoint: CircleWeb.Endpoint,
    router: CircleWeb.Router,
    statics: CircleWeb.static_paths()

  attr :post, :any

  def post(assigns) do
    assigns = assign_new(assigns, :user, fn -> Accounts.get_user!(assigns.post.user_id) end)

    ~H"""
    <.link class="p-2 hover:bg-base-200" phx-click="" navigate={~p"/posts/#{assigns.post}"}>
      <p>{@user.username}</p>
      <p>{@post.content}</p>
    </.link>
    """
  end
end
