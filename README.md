# Karaoke

## Requirements

### MVP

- Participants can visit site and queue up their song choice
- Searches for the given song on YouTube in a new window (just constructs URL: `https://youtube.com/results?search_query={song_name}+karaoke`)
- Restrict access to local RC network
- Mobile-friendly
- Sessions
  - Start a session -> whichever client started now is "admin" of the session (e.g. projector laptop)
  - Participants can Join a given session with a code
  - Admin can only play songs, not delete them
- When session ends, automatically open "Closing Time" song lol

Arch:
- No DB! All in Memory!
- Session data stored in a GenServer
- Everyone connects to the same GenServer
- Use process registry to map session codes to PIDs

Pages:
- / -> Start/join session (static)
- /sessions/ABCD -> Queue for Session ABCD (live view)

![Information Architecture](manual/Information_Architecture.png)

### V1

- Uses RC Oauth & gets names from there
- Finds & suggests videos based on song name/artist
- Embed YouTube videos instead of linking
- More fine-grained access control (e.g. Can only delete your own songs from the queue, No queuing multiple songs at once for the same person)
- Persist to database?

## Development

To start your Phoenix server:

* Run `mix setup` to install and setup dependencies
* Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Deployment

The live app is (usually) available at [karaoke.recurse.com](https://karaoke.recurse.com), which points to [karaoke.gigalixirapp.com](https://karaoke.gigalixirapp.com/).

The app is hosted on [Gigalixir](https://gigalixir.com/docs/) on the free tier, and if there are no changes pushed to the `gigalixir` branch in over 30 days Gigalixir will put the project to sleep. 

To reactivate it: 
`git commit --allow-empty -m "refresh gigalixir"`
`git push gigalixir`

- [ ] TODO: Add a git action to automatically redeploy each month

## Learn more

* Official website: https://www.phoenixframework.org/
* Guides: https://hexdocs.pm/phoenix/overview.html
* Docs: https://hexdocs.pm/phoenix
* Forum: https://elixirforum.com/c/phoenix-forum
* Source: https://github.com/phoenixframework/phoenix
