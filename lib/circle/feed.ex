defmodule Circle.Feed do
  @moduledoc """
  The Feed context.
  """

  import Ecto.Query, warn: false
  require Logger
  alias Circle.Accounts
  alias Circle.Accounts.UserFollowers
  alias Circle.Repo

  alias Circle.Feed.Post
  alias Circle.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any post changes.

  The broadcasted messages match the pattern:

    * {:created, %Post{}}
    * {:updated, %Post{}}
    * {:deleted, %Post{}}

  """
  def subscribe_posts(%Scope{} = scope) do
    topics =
      [scope.user.id | Accounts.get_following_ids_for(scope.user)]
      |> Enum.map(fn key -> "user:#{key}:posts" end)

    Logger.debug("Subscribing to topics #{Enum.join(topics, ", ")}")

    for topic <- topics, do: Phoenix.PubSub.subscribe(Circle.PubSub, topic)
  end

  defp broadcast(id, message) when is_binary(id) do
    Phoenix.PubSub.broadcast(Circle.PubSub, "user:#{id}:posts", message)
  end

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts(scope)
      [%Post{}, ...]

  """
  def list_posts(%Scope{user: user}) do
    follower_ids =
      from followers in UserFollowers,
        where: followers.user_id == ^user.id,
        select: followers.follows_id

    Repo.all(
      from p in Post,
        where: p.user_id == ^user.id or p.user_id in subquery(follower_ids),
        order_by: [desc: p.inserted_at],
        preload: [:user]
    )
    |> Enum.map(fn p -> %{p | user: Accounts.User.prepend_symbol(p.user)} end)
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(scope, 123)
      %Post{}

      iex> get_post!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(%Scope{} = _scope, id) do
    Repo.get_by!(Post, id: id)
  end

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(scope, %{field: value})
      {:ok, %Post{}}

      iex> create_post(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(%Scope{} = scope, attrs) do
    with {:ok, post = %Post{}} <-
           %Post{}
           |> Post.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast(post.user_id, {:created, post})
      {:ok, post}
    end
  end

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(scope, post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(scope, post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_post(%Scope{} = scope, %Post{} = post, attrs) do
    true = Circle.Accounts.Scope.can?(scope, :edit, post)

    with {:ok, post = %Post{}} <-
           post
           |> Post.changeset(attrs, scope)
           |> Repo.update() do
      broadcast(post.user_id, {:updated, post})
      {:ok, post}
    end
  end

  @doc """
  Deletes a post.

  ## Examples

      iex> delete_post(scope, post)
      {:ok, %Post{}}

      iex> delete_post(scope, post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post(%Scope{} = scope, %Post{} = post) do
    true = Circle.Accounts.Scope.can?(scope, :delete, post)

    with {:ok, post = %Post{}} <-
           Repo.delete(post) do
      broadcast(post.user_id, {:deleted, post})
      {:ok, post}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(scope, post)
      %Ecto.Changeset{data: %Post{}}

  """
  def change_post(%Scope{} = scope, %Post{} = post, attrs \\ %{}) do
    true = Circle.Accounts.Scope.can?(scope, :edit, post)

    Post.changeset(post, attrs, scope)
  end
end
