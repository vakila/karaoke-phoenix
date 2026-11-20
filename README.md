# Karaoke!

It's Karaoke! It's Elixir & Phoenix! It's Recurse!


## Deployment

The app is hosted on [RC's Disco server](https://disco.recurse.com/).

The live app is (usually) available at [karaoke.recurse.com](https://karaoke.recurse.com), which points to [karaoke.rcdis.co](http://karaoke.rcdis.co).

Whenever code is pushed to the `main` branch of this repo, Disco should pick up the changes and redeploy the site (give it a minute). 

Previously the app was hosted on Gigalixir. The old gigalixir actions in this repo are now disabled because hosting on Disco is way more awesome. 


### Oh no! karaoke.recurse.com is down! :(

Don't panic! Grab your towel, and wipe off the karaoke sweat. and 

A new push to the `main` branch should trigger a redeploy, if need be (e.g. revert and push the previous bad change). 

You can use the [Disco CLI](https://disco.cloud/docs/cli/reference/) to see what the deal is. Try to check the Disco logs for the 'karaoke' project or redeploy the project manually if need be. 


### Docker
The app can be run in a [Docker](https://docs.docker.com/) container built from the `Dockerfile` in this repo. 

The `Dockerfile`, `.dockerignore`, and `rel/` were generated with: 

```
$ mix phx.gen.release --docker
```

To build and run the container locally: 

```
$ docker build -t karaoke .
$ docker run \
  -e SECRET_KEY_BASE="$(mix phx.gen.secret)" \
  -e PHX_HOST="localhost" \
  -e PORT=4000 \
  -p 4000:4000 \
  karaoke 
```



## Development

To start the Phoenix server:

* Run `mix setup` to install and setup dependencies
* Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.



### Learn more about Phoenix

* Official website: https://www.phoenixframework.org/
* Guides: https://hexdocs.pm/phoenix/overview.html
* Docs: https://hexdocs.pm/phoenix
* Forum: https://elixirforum.com/c/phoenix-forum
* Source: https://github.com/phoenixframework/phoenix



## Notes

### Features

- Participants can visit site and queue up their song choice
- Queued songs can be edited and deleted
- Searches & suggests videos from YouTube based on song name/artist
- Embeds YouTube videos in page when possible, otherwise links to YouTube in new tab
- The last song can be recovered if you accidentally skipped it

Arch:
- No DB! All in Memory!
- Queue data stored in a GenServer, which all clients connect to
- Live updates to frontend handled by Phoenix LiveView


### Future Ideas

- See open issues
- Use RC Oauth & gets names from there
- More fine-grained access control (e.g. Can only delete your own songs from the queue, No queuing multiple songs at once for the same person)
- Persist to database?


