defmodule KaraokeWeb.PageController do
  use KaraokeWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end


end


defmodule KaraokeWeb.SessionController do
  use KaraokeWeb, :controller

  def index(conn, _params) do
    redirect(conn, to: "/")
  end

  def show(conn, %{"id" => id}) do
    # render(conn, :session)
    text(conn, "This is session #{id}")
  end
end
