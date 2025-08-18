defmodule Circle.Accounts.Policy.PostPolicy do
  alias Circle.Accounts.User
  alias Circle.Accounts.Scope
  alias Circle.Feed.Post

  def can(%Scope{user: %User{id: id}}, _action, %Post{user_id: id}),
    do: :ok

  def can(%Scope{role: :admin}, action, %Post{}) when action in [:show, :delete],
    do: :ok

  def can(%Scope{}, :show, %Post{}),
    do: :ok

  def can(%Scope{}, _action, %Post{}),
    do: :error
end
