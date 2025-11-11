defmodule KaraokeWeb.QueuedSongLive do
  use KaraokeWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>I am a queued song {@song.id}</div>
    """

    end

  @impl true
  def update(assigns, socket) do
    {:ok, socket |> assign(assigns)}
  end

  @impl true
  def mount(assigns, socket) do
    {:ok, socket |> assign(assigns)}
  end
end
