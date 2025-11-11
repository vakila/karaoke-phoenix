defmodule KaraokeWeb.PageController do
  use KaraokeWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end

  def session(conn, %{"id" => id}) do
    render(conn, :session, id: id)
    # text(conn, "This is session #{id}")
  end

end
