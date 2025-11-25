defmodule Karaoke.Party do
  @moduledoc """
  The Party (aka queue) context.

  And server
  """

  # alias Karaoke.Party.Queue
  alias Karaoke.Party.Song

  use GenServer

  @doc """
  Starts a new party aka song queue.
  """
  def start_link(opts) do
    {:ok, pid} = GenServer.start_link(__MODULE__, [], opts)
    dbg(pid)
    {:ok, pid}
  end


  @doc """
  Gets all the songs in the queue.
  """
  def list_songs(party) do
    GenServer.call(party, {:list})
  end



  @doc """
  Gets the next song from the queue.
  """
  def next_song(party) do
    GenServer.call(party, {:next})
  end

  @doc """
  Appends the `song` to the queue.
  """
  def add_song(party, song) do
    GenServer.call(party, {:add, song})
  end

  @doc """
  Deletes song at `song_index` from `party` queue.

  Returns the current song at `song_index`, if one exists.
  """
  def delete_song(party, song_index) do
    GenServer.call(party, {:delete, song_index})
  end


  @doc """
  Updates a song.

  ## Examples

      iex> update_song(song, %{field: new_value})
      {:ok, %Song{}}

      iex> update_song(song, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def edit_song(party, song) do
    GenServer.call(party, {:edit, song})
  end



  @doc """
  Subscribes the current process to the party.
  """
  def subscribe(party) do
    GenServer.call(party, {:subscribe, self()})
  end


  defp broadcast(party, message) do
    for pid <- party.subscribers do
      send(pid, message)
    end
  end


  # #### Callbacks


  @impl true
  def init(songs) do
    party = %{
      pid: self(),
      queue: songs,
      subscribers: MapSet.new([])
    }
    dbg(self())
    {:ok, party}
  end

  def match_song_id(%Song{} = song, id) do
    song.id == id
  end

  @impl true
  def handle_call({:edit, song}, _from, party) do
    song_index = Enum.find_index(party.queue, &match_song_id(&1, song.id))
    dbg("UPDATE")
    dbg(party.queue)
    dbg(song_index)
    dbg(song)
    new_queue = List.replace_at(party.queue, song_index, song)
    new_party = put_in(party.queue, new_queue)
    broadcast(party, {:updated, new_party})
    {:reply, new_queue, new_party}
  end



  @impl true
  def handle_call({:add, song}, _from, party) do
    new_queue = List.insert_at(party.queue, -1, song)
    new_party = put_in(party.queue, new_queue)
    broadcast(party, {:updated, new_party})
    {:reply, new_queue, new_party }
  end


  @impl true
  def handle_call({:delete, song_index}, _from, party) do
    {_song, new_queue} = List.pop_at(party.queue, song_index)
    new_party = put_in(party.queue, new_queue)
    broadcast(party, {:updated, new_party})
    {:reply, new_queue, new_party}
  end



  @impl true
  def handle_call({:next}, _from, party) do
    [next_song | new_queue] = party.queue
    new_party = put_in(party.queue, new_queue)
    broadcast(party, {:updated, next_song, new_queue})
    {:reply, next_song, new_party}
  end



  @impl true
  def handle_call({:list}, _from, party) do
    {:reply, party.queue, party}
  end


  @impl true
  def handle_call({:subscribe, pid}, _from, party) do
    Process.monitor(pid)
    party = update_in(party.subscribers, &MapSet.put(&1, pid))
    broadcast(party, {:updated, party})
    {:reply, party, party}
  end

  @impl true
  def handle_info({:DOWN, _ref, _type, pid, _reason}, party) do
    party = update_in(party.subscribers, &MapSet.delete(&1, pid))
    broadcast(party, {:updated, party})
    {:noreply, party}
  end





end
