defmodule CircleWeb.PostLiveTest do
  use CircleWeb.ConnCase

  import Phoenix.LiveViewTest
  import Circle.FeedFixtures
  import Circle.AccountsFixtures

  @create_attrs %{content: "some content"}
  @update_attrs %{content: "some updated content"}
  @invalid_attrs %{content: nil}

  setup :register_and_log_in_user

  defp create_post(%{scope: scope}) do
    post = post_fixture(scope)

    %{post: post}
  end

  describe "Index" do
    setup [:create_post]

    test "lists all posts", %{conn: conn, post: post} do
      {:ok, _index_live, html} = live(conn, ~p"/posts")

      assert html =~ "Listing Posts"
      assert html =~ post.content
    end

    test "saves new post", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/posts")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Post")
               |> render_click()
               |> follow_redirect(conn, ~p"/posts/new")

      assert render(form_live) =~ "New Post"

      assert form_live
             |> form("#post-form", post: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#post-form", post: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/posts")

      html = render(index_live)
      assert html =~ "Post created successfully"
      assert html =~ "some content"
    end

    test "updates post in listing", %{conn: conn, post: post} do
      {:ok, index_live, _html} = live(conn, ~p"/posts")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#posts-#{post.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/posts/#{post}/edit")

      assert render(form_live) =~ "Edit Post"

      assert form_live
             |> form("#post-form", post: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#post-form", post: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/posts")

      html = render(index_live)
      assert html =~ "Post updated successfully"
      assert html =~ "some updated content"
    end

    test "deletes post in listing", %{conn: conn, post: post} do
      {:ok, index_live, _html} = live(conn, ~p"/posts")

      assert index_live |> element("#posts-#{post.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#posts-#{post.id}")
    end

    test "adds following post to listing", %{conn: conn} do
      # setup
      user1 = user_fixture()
      user2 = user_fixture()
      scope2 = user_scope_fixture(user2)

      Circle.Accounts.follow_user(user1, user2)

      conn1 = log_in_user(conn, user1)
      {:ok, index_live, html} = live(conn1, ~p"/posts")

      # act
      refute html =~ "Hello followers!"

      {:ok, _} = Circle.Feed.create_post(scope2, %{content: "Hello followers!"})

      assert render(index_live) =~ "Hello followers!"
    end

    test "updates following post to listing", %{conn: conn} do
      # setup
      user1 = user_fixture()
      user2 = user_fixture()
      scope2 = user_scope_fixture(user2)

      Circle.Accounts.follow_user(user1, user2)

      {:ok, f_post} = Circle.Feed.create_post(scope2, %{content: "Hello followers!"})

      conn1 = log_in_user(conn, user1)
      {:ok, index_live, html} = live(conn1, ~p"/posts")

      # act
      assert html =~ "Hello followers!"

      {:ok, _} = Circle.Feed.update_post(scope2, f_post, %{content: "Hello to all my followers!"})

      assert render(index_live) =~ "Hello to all my followers!"
    end

    test "deletes following post to listing", %{conn: conn} do
      # setup
      user1 = user_fixture()
      user2 = user_fixture()
      scope2 = user_scope_fixture(user2)

      Circle.Accounts.follow_user(user1, user2)

      {:ok, f_post} = Circle.Feed.create_post(scope2, %{content: "Hello followers!"})

      conn1 = log_in_user(conn, user1)
      {:ok, index_live, html} = live(conn1, ~p"/posts")

      # act
      assert html =~ "Hello followers!"

      {:ok, _} = Circle.Feed.delete_post(scope2, f_post)

      refute render(index_live) =~ "Hello followers!"
    end
  end

  describe "Show" do
    setup [:create_post]

    test "displays post", %{conn: conn, post: post} do
      {:ok, _show_live, html} = live(conn, ~p"/posts/#{post}")

      assert html =~ "Show Post"
      assert html =~ post.content
    end

    test "updates post and returns to show", %{conn: conn, post: post} do
      {:ok, show_live, _html} = live(conn, ~p"/posts/#{post}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/posts/#{post}/edit?return_to=show")

      assert render(form_live) =~ "Edit Post"

      assert form_live
             |> form("#post-form", post: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#post-form", post: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/posts/#{post}")

      html = render(show_live)
      assert html =~ "Post updated successfully"
      assert html =~ "some updated content"
    end
  end
end
