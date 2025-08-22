defmodule Circle.FeedTest do
  use Circle.DataCase

  alias Circle.Feed

  describe "posts" do
    alias Circle.Feed.Post

    import Circle.AccountsFixtures
    import Circle.FeedFixtures

    @invalid_attrs %{content: nil}

    test "list_posts/1 returns all scoped posts" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      post = post_fixture(scope) |> Circle.Repo.preload([:user])
      post = %{post | user: Circle.Accounts.User.prepend_symbol(post.user)}
      other_post = post_fixture(other_scope) |> Circle.Repo.preload([:user])
      other_post = %{other_post | user: Circle.Accounts.User.prepend_symbol(other_post.user)}
      assert Feed.list_posts(scope) == [post]
      assert Feed.list_posts(other_scope) == [other_post]
    end

    test "list_posts/1 returns followers posts" do
      u1 = user_fixture()
      scope = user_scope_fixture(u1)
      u2 = user_fixture()
      post1 = post_fixture(user_scope_fixture(u2)) |> Circle.Repo.preload([:user])
      post1 = %{post1 | user: Circle.Accounts.User.prepend_symbol(post1.user)}
      post2 = post_fixture(scope) |> Circle.Repo.preload([:user])
      post2 = %{post2 | user: Circle.Accounts.User.prepend_symbol(post2.user)}

      Circle.Accounts.follow_user(u1, u2)

      assert Feed.list_posts(scope) == [post1, post2]
    end

    test "get_post!/2 returns the post with given id" do
      scope = user_scope_fixture()
      post = post_fixture(scope)
      assert Feed.get_post!(scope, post.id) == post
    end

    test "create_post/2 with valid data creates a post" do
      valid_attrs = %{content: "some content"}
      scope = user_scope_fixture()

      assert {:ok, %Post{} = post} = Feed.create_post(scope, valid_attrs)
      assert post.content == "some content"
      assert post.user_id == scope.user.id
    end

    test "create_post/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Feed.create_post(scope, @invalid_attrs)
    end

    test "update_post/3 with valid data updates the post" do
      scope = user_scope_fixture()
      post = post_fixture(scope)
      update_attrs = %{content: "some updated content"}

      assert {:ok, %Post{} = post} = Feed.update_post(scope, post, update_attrs)
      assert post.content == "some updated content"
    end

    test "update_post/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      post = post_fixture(scope)

      assert_raise MatchError, fn ->
        Feed.update_post(other_scope, post, %{})
      end
    end

    test "update_post/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      post = post_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Feed.update_post(scope, post, @invalid_attrs)
      assert post == Feed.get_post!(scope, post.id)
    end

    test "delete_post/2 deletes the post" do
      scope = user_scope_fixture()
      post = post_fixture(scope)
      assert {:ok, %Post{}} = Feed.delete_post(scope, post)
      assert_raise Ecto.NoResultsError, fn -> Feed.get_post!(scope, post.id) end
    end

    test "delete_post/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      post = post_fixture(scope)
      assert_raise MatchError, fn -> Feed.delete_post(other_scope, post) end
    end

    test "change_post/2 returns a post changeset" do
      scope = user_scope_fixture()
      post = post_fixture(scope)
      assert %Ecto.Changeset{} = Feed.change_post(scope, post)
    end
  end
end
