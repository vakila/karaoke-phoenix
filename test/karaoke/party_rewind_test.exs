defmodule Karaoke.PartyRewindTest do
  use ExUnit.Case, async: true

  alias Karaoke.Party
  alias Karaoke.Party.Song

  defp song(singer), do: %Song{id: singer, singer: singer, title: "#{singer}'s song"}

  # each test gets its own unnamed party so it doesn't share the app's queue
  defp party_with(singers) do
    party = start_supervised!({Party, []})
    for singer <- singers, do: Party.add_song(party, song(singer))
    party
  end

  defp state(party) do
    %{playing: playing, previous: previous, queue: queue} = :sys.get_state(party)

    %{
      playing: playing && playing.singer,
      previous: previous && previous.singer,
      queue: Enum.map(queue, & &1.singer)
    }
  end

  test "next remembers the song that just played" do
    party = party_with(["A", "B", "C"])
    Party.next_song(party)
    assert state(party) == %{playing: "A", previous: nil, queue: ["B", "C"]}

    Party.next_song(party)
    assert state(party) == %{playing: "B", previous: "A", queue: ["C"]}
  end

  test "rewind undoes an accidental double next" do
    party = party_with(["A", "B", "C"])
    Party.next_song(party)

    # oops, double click skipped B
    Party.next_song(party)
    Party.next_song(party)
    assert state(party) == %{playing: "C", previous: "B", queue: []}

    Party.rewind(party)
    assert state(party) == %{playing: "B", previous: nil, queue: ["C"]}
  end

  test "you can only rewind once" do
    party = party_with(["A", "B", "C"])
    Party.next_song(party)
    Party.next_song(party)

    Party.rewind(party)
    after_first = state(party)
    assert after_first == %{playing: "A", previous: nil, queue: ["B", "C"]}

    Party.rewind(party)
    assert state(party) == after_first
  end

  test "rewind with nothing played is a no-op" do
    party = party_with(["A"])
    Party.rewind(party)
    assert state(party) == %{playing: nil, previous: nil, queue: ["A"]}
  end

  test "rewind after the party ends brings back the last song" do
    party = party_with(["A"])
    Party.next_song(party)
    Party.next_song(party)
    assert state(party) == %{playing: nil, previous: "A", queue: []}

    Party.rewind(party)
    assert state(party) == %{playing: "A", previous: nil, queue: []}
  end

  test "rewind broadcasts the update to subscribers" do
    party = party_with(["A", "B"])
    Party.next_song(party)
    Party.next_song(party)

    Party.subscribe(party)
    # subscribing broadcasts the current state; drain it
    assert_receive {:updated, %{playing: %Song{singer: "B"}}}

    Party.rewind(party)
    assert_receive {:updated, %{playing: %Song{singer: "A"}, previous: nil}}
  end
end
