# Karaoke

## Requirements

### MVP

- Participants can visit site and queue up their song choice
- Searches for the given song on YouTube in a new window (just constructs URL: `https://youtube.com/results?search_query={song_name}+karaoke`)
- Restrict access to local RC network
- Mobile-friendly
- Sessions
  - Start a session -> whichever client started now is "admin" of the session (e.g. projector laptop)
  - Join a given session with a code
- No DB! All in Memory! 

### V1

- Uses RC Oauth & gets names from there
- Finds & suggests videos based on song name/artist
- Embed YouTube videos
- No queuing multiple songs at once for the same person
- Persist to database

## Development

To start your Phoenix server:

* Run `mix setup` to install and setup dependencies
* Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

* Official website: https://www.phoenixframework.org/
* Guides: https://hexdocs.pm/phoenix/overview.html
* Docs: https://hexdocs.pm/phoenix
* Forum: https://elixirforum.com/c/phoenix-forum
* Source: https://github.com/phoenixframework/phoenix
