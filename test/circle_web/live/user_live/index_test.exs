defmodule CircleWeb.UserLive.IndexTest do
  use CircleWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Circle.AccountsFixtures

  def seed_users(context) do
    users =
      for _ <- 1..5 do
        unconfirmed_user_fixture()
      end

    Map.put(context, :users, users)
  end

  describe "index page" do
    setup [:seed_users]

    test "renders index page", %{conn: conn} do
      {:ok, _lv, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/users")

      assert html =~ "User names"
    end

    test "requires authentication", %{conn: conn} do
      {:error, {:redirect, %{to: "/users/log-in"}}} =
        conn
        |> live(~p"/users")
    end

    test "renders user list", %{conn: conn, users: [u | _]} do
      {:ok, _lv, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/users")

      assert html =~ "Follow"
      assert html =~ u.username
    end

    test "can follow a user", %{conn: conn, users: [u1, u2 | _]} do
      {:ok, view, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/users")

      html =
        view
        |> element("#users-#{u1.id} button", "Follow")
        |> render_click()

      assert html =~ "Unfollow"
      refute view |> element("#users-#{u1.id} button", "Follow") |> has_element?()
    end

    test "followed users render unfollow button", %{conn: conn, users: [u1, u2 | _]} do
      conn =
        conn
        |> log_in_user(u1)

      scope = Circle.Accounts.Scope.for_user(u1)
      Circle.Accounts.follow_user(scope.user, u2)

      {:ok, view, html} =
        conn
        |> live(~p"/users")

      assert html =~ "Unfollow"

      assert view
             |> element("#users-#{u2.id} button", "Unfollow")
             |> has_element?()
    end

    test "can unfollow a user", %{conn: conn, users: [u1, u2 | _]} do
      conn =
        conn
        |> log_in_user(u1)

      scope = Circle.Accounts.Scope.for_user(u1)
      Circle.Accounts.follow_user(scope.user, u2)

      {:ok, view, html} =
        conn
        |> live(~p"/users")

      assert html =~ "Unfollow"

      html =
        assert view
               |> element("#users-#{u2.id} button", "Unfollow")
               |> render_click()

      refute html =~ "Unfollow"

      assert view
             |> element("#users-#{u2.id} button", "Follow")
             |> has_element?()
    end
  end
end
