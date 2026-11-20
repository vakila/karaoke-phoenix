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
  def start_link(opts) do
    GenServer.start_link(__MODULE__, [], opts)
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
  Rewinds to the previous song, like the REW key on a tape deck.

  The previous song becomes the playing song again, and whatever was playing
  goes back to the front of the queue. Only one previous song is remembered,
  so you can only rewind once per "next" - after rewinding there's nothing
  left to rewind to. Rewinding with no previous song is a no-op.
  """
  def rewind(party) do
    GenServer.call(party, {:rewind})
  end

  @doc """
  Appends the `song` to the queue.
  """
  def add_song(party, song) do
    GenServer.call(party, {:add, song})
  end

  @doc """
  Deletes song with `song_id` from `party` queue.

  Returns the deleted song, if it exists.
  """
  def delete_song(party, song_id) do
    GenServer.call(party, {:delete, song_id})
  end

  @doc """
  Updates a song.

  ## Examples

      iex> edit_song(song, %{field: new_value})
      {:ok, %Song{}}

      iex> edit_song(song, %{field: bad_value})
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
      subscribers: MapSet.new([]),
      playing: nil,
      # the last song that played, so an accidental "next" can be rewound
      previous: nil
    }

    dbg(self())
    {:ok, party}
  end

  def match_song_id(%Song{} = song, id) do
    song.id == id
  end

  def get_song_index(queue, %Song{} = song) do
    Enum.find_index(queue, &match_song_id(&1, song.id))
  end

  def get_song_index(queue, song_id) do
    Enum.find_index(queue, &match_song_id(&1, song_id))
  end

  @impl true
  def handle_call({:edit, song}, _from, party) do
    case get_song_index(party.queue, song.id) do
      nil ->
        # the song left the queue (played or deleted) while being edited;
        # ignore the edit rather than crashing and losing the whole party
        {:reply, party.queue, party}

      song_index ->
        new_queue = List.replace_at(party.queue, song_index, song)
        new_party = put_in(party.queue, new_queue)
        broadcast(party, {:updated, new_party})
        {:reply, new_queue, new_party}
    end
  end

  @impl true
  def handle_call({:add, song}, _from, party) do
    new_queue = List.insert_at(party.queue, -1, song)
    new_party = put_in(party.queue, new_queue)
    broadcast(party, {:updated, new_party})
    {:reply, new_queue, new_party}
  end

  @impl true
  def handle_call({:delete, song_id}, _from, party) do
    case get_song_index(party.queue, song_id) do
      nil ->
        # already gone (e.g. two people hit delete); nothing to do
        {:reply, party.queue, party}

      song_index ->
        {_song, new_queue} = List.pop_at(party.queue, song_index)
        new_party = put_in(party.queue, new_queue)
        broadcast(party, {:updated, new_party})
        {:reply, new_queue, new_party}
    end
  end

  @impl true
  def handle_call({:next}, _from, party) do
    %{playing: old_song, queue: old_queue} = party

    case old_queue do
      [] ->
        if old_song == nil do
          # no-op, the party was already over
          {:reply, party, party}
        else
          # the party is over now, broadcast update
          new_party = %{party | playing: nil, previous: old_song}
          broadcast(party, {:updated, new_party})
          {:reply, new_party, new_party}
        end

      [new_playing | new_queue] ->
        # move the party along, remembering what just played
        new_party = %{party | playing: new_playing, queue: new_queue, previous: old_song}
        broadcast(party, {:updated, new_party})
        {:reply, new_party, new_party}
    end
  end

  @impl true
  def handle_call({:rewind}, _from, %{previous: nil} = party) do
    # nothing to rewind to (never played, or already rewound)
    {:reply, party, party}
  end

  @impl true
  def handle_call({:rewind}, _from, party) do
    %{playing: current, previous: previous, queue: queue} = party

    # put whoever is on now back at the front of the line
    new_queue = if current, do: [current | queue], else: queue

    new_party = %{party | playing: previous, queue: new_queue, previous: nil}
    broadcast(party, {:updated, new_party})
    {:reply, new_party, new_party}
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
    dbg(party)
    {:reply, party, party}
  end

  @impl true
  def handle_info({:DOWN, _ref, _type, pid, _reason}, party) do
    party = update_in(party.subscribers, &MapSet.delete(&1, pid))
    broadcast(party, {:updated, party})
    {:noreply, party}
  end
end
