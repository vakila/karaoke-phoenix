# Karaoke!

It's Karaoke! It's Elixir & Phoenix! It's Recurse!

## Development

To start your Phoenix server:

* Run `mix setup` to install and setup dependencies
* Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

### Tests

Ignore them! They are broken on main! 

- [ ] TODO fix that!


## Deployment

The live app is (usually) available at [karaoke.recurse.com](https://karaoke.recurse.com), which points to [karaoke.gigalixirapp.com](https://karaoke.gigalixirapp.com/).

Whenever code is pushed to the `main` branch of this repo, the `gigalixir-deploy.yml` Github Action runs to deploy the updated version to Gigalixir. That action can also be triggered manually if need be. 

Credentials for the Gigalixir login (@vakila's account) are stored as secrets in this repo's settings.


### Oh no! karaoke.recurse.com is down! :(

Don't panic! Grab your towel, wipe off the karaoke sweat and redeploy the app.

The app is hosted on [Gigalixir](https://gigalixir.com/docs/) on the free tier, so if there are no new deploys of the project in over 30 days Gigalixir will deactivate the project and scale down the deployment to 0 replicas. 

To resuscitate the app without pushing any changes, you can manually run the `gigalixir-scale.yml` Github Action to tell Gigalixir to scale the project back up to 1 replica. This action is (theoretically) also scheduled to run automatically once per month.



## Planning Notes

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

