defmodule Karaoke.Party do
  @moduledoc """
  The Party (aka queue) context.

  And server
  """

  alias Karaoke.Party.Song

  use GenServer


  @doc """
  Starts a new party aka song queue.
  """
  def start_link(songs \\ [], opts) do
    GenServer.start_link(__MODULE__, songs, opts)
  end


  @doc """
  Gets the next song from `party` queue.
  """
  def list_songs(party) do
    GenServer.call(party.pid, {:list})
  end



  @doc """
  Gets the next song from `party` queue.
  """
  def next_song(party) do
    GenServer.call(party.pid, {:next})
  end


  # @doc """
  # Gets the `party` song queue.
  # """
  # def list_songs(party) do
  #   GenServer.call(party, {:list})
  # end

  @doc """
  Appends the `song` to the `party` queue.
  """
  def add_song(party, song) do
    GenServer.call(party.pid, {:add, song})
  end

  @doc """
  Deletes song at `song_index` from `party` queue.

  Returns the current song at `song_index`, if one exists.
  """
  def delete_song(party, song_index) do
    GenServer.call(party.pid, {:delete, song_index})
  end




  @doc """
  Updates a song.

  ## Examples

      iex> update_song(song, %{field: new_value})
      {:ok, %Song{}}

      iex> update_song(song, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_song(party, song_index, song) do
    GenServer.call(party.pid, {:update, song_index, song})
  end

  def validate_song(song) do
    changeset = Song.to_changeset(song)
    if (!changeset.valid?) do
      {:error, changeset}
    end
    {:ok, changeset}
  end

  #### Callbacks


  @impl true
  def init(queue \\ []) do
    party = %{
      pid: self(),
      queue: queue,
    }

    {:ok, party }
  end

  @impl true
  def handle_call({:update, song_index, song}, _from, party) do
    new_queue = List.update_at(party.queue, song_index, song)
    {:reply, :ok, Enum.into(party.queue, new_queue)}
  end



  @impl true
  def handle_call({:add, song}, _from, party) do
    new_queue = party.queue ++ [song]
    {:reply, :ok,  Enum.into(party.queue, new_queue)}
  end


  @impl true
  def handle_call({:delete, song_index}, _from, party) do
    new_queue = List.delete_at(party.queue, song_index)
    {:reply, :ok, Enum.into(party.queue, new_queue)}
  end



  @impl true
  def handle_call({:next}, _from, party) do
    [next_song | new_queue] = party.queue
    {:reply, next_song, Enum.into(party.queue, new_queue)}
  end



  @impl true
  def handle_call({:list}, _from, party) do
    {:reply, party.queue, party}
  end






end
