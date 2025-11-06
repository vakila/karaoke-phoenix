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


defmodule KaraokeWeb.SessionController do
  use KaraokeWeb, :controller

  def index(conn, _params) do
    redirect(conn, to: "/")
  end

  def new(conn, _params) do
    redirect(conn, to: "/sessions/1234") # TODO
  end

  def show(conn, %{"id" => id}) do
    render(conn, :session, id: id, songs: [
      %{name: "Living on the edge", singer: "Anjana"},
      %{name: "Bohemian Rhapsody", singer: "Joseph"},
      %{name: "On the road again", singer: "Flavius"},
      %{name: "Closing Time", singer: "Everyone"}
      ])
  end
end
