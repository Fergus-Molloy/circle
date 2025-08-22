defmodule CircleWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use CircleWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """
  alias Circle.Repo

  use ExUnit.CaseTemplate

  using do
    quote do
      # The default endpoint for testing
      @endpoint CircleWeb.Endpoint

      use CircleWeb, :verified_routes

      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import CircleWeb.ConnCase
    end
  end

  setup tags do
    Circle.DataCase.setup_sandbox(tags)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  @doc """
  Setup helper that registers and logs in users.

      setup :register_and_log_in_user

  It stores an updated connection and a registered user in the
  test context.
  """
  def register_and_log_in_user(%{conn: conn} = context) do
    user = Circle.AccountsFixtures.user_fixture()
    following = Circle.AccountsFixtures.user_fixture()
    Circle.Accounts.follow_user(user, following)

    {:ok, following_post} =
      Circle.Feed.create_post(%Circle.Accounts.Scope{user: following}, %{
        "content" => "some following content"
      })

    user = Repo.preload(user, [:following])

    scope = Circle.Accounts.Scope.for_user(user)

    opts =
      context
      |> Map.take([:token_authenticated_at])
      |> Enum.into([])

    %{
      conn: log_in_user(conn, user, opts),
      user: user,
      scope: scope,
      following_post: following_post
    }
  end

  @doc """
  Logs the given `user` into the `conn`.

  It returns an updated `conn`.
  """
  def log_in_user(conn, user, opts \\ []) do
    token = Circle.Accounts.generate_user_session_token(user)

    maybe_set_token_authenticated_at(token, opts[:token_authenticated_at])

    conn
    |> Phoenix.ConnTest.init_test_session(%{})
    |> Plug.Conn.put_session(:user_token, token)
  end

  defp maybe_set_token_authenticated_at(_token, nil), do: nil

  defp maybe_set_token_authenticated_at(token, authenticated_at) do
    Circle.AccountsFixtures.override_token_authenticated_at(token, authenticated_at)
  end
end
