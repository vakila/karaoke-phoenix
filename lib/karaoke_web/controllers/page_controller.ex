defmodule KaraokeWeb.PageController do
  use KaraokeWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
