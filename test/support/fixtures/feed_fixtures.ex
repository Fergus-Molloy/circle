defmodule Circle.FeedFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Circle.Feed` context.
  """

  @doc """
  Generate a post.
  """
  def post_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        content: "some content"
      })

    {:ok, post} = Circle.Feed.create_post(scope, attrs)
    post
  end
end
