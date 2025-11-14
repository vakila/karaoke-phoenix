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
  Gets the next song from `party` queue.
  """
  def next_song(party) do
    GenServer.call(party, {:next})
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
  def add_song(party, %Song{} = song) do
    GenServer.call(party, {:add, song})
  end

  @doc """
  Deletes song at `s` from `party` queue.

  Returns the current value of `song_id`, if `song_id` exists.
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
  def update_song(party, song_index, song) do
    GenServer.call(party, {:update, song_index, song})
  end



  #### Callbacks


  @impl true
  def init(queue \\ []) do
    party = %{
      queue: queue,
    }

    {:ok, party }
  end

  @impl true
  def handle_cast({:update, song_index, song}, party) do
    new_queue = List.update_at(party.queue, song_index, song)
    {:reply, :ok, %{queue: new_queue}}
  end



  @impl true
  def handle_cast({:add, song}, party) do
    # new_party = [ song |  party ]
    new_queue = party.queue ++ [song]
    {:noreply, %{queue: new_queue}}
  end


  @impl true
  def handle_cast({:delete, song_index}, party) do
    new_queue = List.delete_at(party.queue, song_index)
    {:reply, :ok, %{queue: new_queue}}
  end



  @impl true
  def handle_call({:next}, _from, party) do
    [next_song | new_queue] = party.queue
    {:reply, next_song, %{queue: new_queue}}
  end



  @impl true
  def handle_call({:list}, _from, party) do
    [next_song | new_queue] = party.queue
    {:reply, next_song, %{queue: new_queue}}
  end






end
