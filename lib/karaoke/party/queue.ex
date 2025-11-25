defmodule Karaoke.Party.Queue do


  alias Karaoke.Party.Song

  use GenServer



  @doc """
  Starts a new party aka song queue.
  """
  def start_link(songs \\ [], opts) do
    GenServer.start_link(__MODULE__, songs, opts)
  end


  # @doc """
  # Gets the next song from `party` queue.
  # """
  # def list_songs() do
  #   # GenServer.call(party.pid, {:list})

  # end



  # @doc """
  # Gets the next song from `party` queue.
  # """
  # def next_song(queue) do
  #   GenServer.call(queue.pid, {:next})
  # end


  # # @doc """
  # # Gets the `party` song queue.
  # # """
  # # def list_songs(party) do
  # #   GenServer.call(party, {:list})
  # # end

  # @doc """
  # Appends the `song` to the `party` queue.
  # """
  # def add_song(party, song) do
  #   GenServer.call(party.pid, {:add, song})
  # end

  # @doc """
  # Deletes song at `song_index` from `party` queue.

  # Returns the current song at `song_index`, if one exists.
  # """
  # def delete_song(party, song_index) do
  #   GenServer.call(party.pid, {:delete, song_index})
  # end




  # @doc """
  # Updates a song.

  # ## Examples

  #     iex> update_song(song, %{field: new_value})
  #     {:ok, %Song{}}

  #     iex> update_song(song, %{field: bad_value})
  #     {:error, %Ecto.Changeset{}}

  # """
  # def update_song(party, song_index, song) do
  #   GenServer.call(party.pid, {:update, song_index, song})
  # end

  # #### Callbacks


  @impl true
  def init(songs \\ []) do
    queue = %{
      pid: self(),
      songs: songs
    }

    {:ok, queue }
  end

  @impl true
  def handle_call({:update, song_index, song}, _from, queue) do
    new_songs = List.update_at(queue.songs, song_index, song)
    {:reply, song, Map.replace(queue, "songs", new_songs)}
  end



  @impl true
  def handle_call({:add, song}, _from, queue) do
    new_songs = queue.songs ++ [song]
    {:reply, song, Map.replace(queue, "songs", new_songs)}
  end


  @impl true
  def handle_call({:delete, song_index}, _from, queue) do
    {deleted_song, new_songs} = List.pop_at(queue.songs, song_index)
    {:reply, deleted_song, Map.replace(queue, "songs", new_songs) }
  end



  @impl true
  def handle_call({:next}, _from, queue) do
    [next_song | new_songs] = queue.songs
    {:reply, next_song, Map.replace(queue, "songs", new_songs)}
  end



  @impl true
  def handle_call({:list}, _from, queue) do
    {:reply, queue.songs, queue}
  end





end
