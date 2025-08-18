defmodule Circle.Accounts.Scope do
  @moduledoc """
  Defines the scope of the caller to be used throughout the app.

  The `Circle.Accounts.Scope` allows public interfaces to receive
  information about the caller, such as if the call is initiated from an
  end-user, and if so, which user. Additionally, such a scope can carry fields
  such as "super user" or other privileges for use as authorization, or to
  ensure specific code paths can only be access for a given scope.

  It is useful for logging as well as for scoping pubsub subscriptions and
  broadcasts when a caller subscribes to an interface or performs a particular
  action.

  Feel free to extend the fields on this struct to fit the needs of
  growing application requirements.
  """

  alias Circle.Accounts.User
  alias Circle.Feed.Post

  defstruct user: nil, role: nil

  @doc """
  Creates a scope for the given user.

  Returns nil if no user is given.
  """
  def for_user(%User{is_admin: true} = user) do
    %__MODULE__{user: user, role: :admin}
  end

  def for_user(%User{} = user) do
    %__MODULE__{user: user, role: :user}
  end

  def for_user(nil), do: nil

  @doc """
  Check if current scope can perform the given action on the given item

  Returns true if user can perform action, false otherwise
  """
  def can?(scope, action, item) do
    case get_policy_for(item) |> apply([scope, action, item]) do
      :ok -> true
      _ -> false
    end
  end

  defp get_policy_for(%Post{}), do: &Circle.Accounts.Policy.PostPolicy.can/3
  defp get_policy_for(%{}), do: fn _, _, _ -> raise "policy not defined" end
end
