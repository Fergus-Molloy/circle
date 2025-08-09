defmodule CircleWeb.PageController do
  use CircleWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
