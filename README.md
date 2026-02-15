# Ex338

A web application to manage the 338 Challenge Fantasy League built using [Elixir](https://elixir-lang.org/)
and [Phoenix](https://www.phoenixframework.org/). The 338 Challenge is a
fantasy sports league where you pick teams instead of players and get points
when your team wins its league championship.

The draft, waivers, and trades are accomplished through the website. The league
is set up to have multiple divisions (with relegation).

### Home Page

![Home Page](/README_assets/ex338_home_screen.png?raw=true "Home Page")

<br />
<br />

### List of Players

![Players Page](/README_assets/ex338_fantasy_players_screen.png?raw=true "Players")

## Setup

To start your Phoenix server:

- Run `mix setup` to install and setup dependencies
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Local development (no Docker)

### Prerequisites

- Elixir/Erlang (see `mix.exs` for current version requirement)
- PostgreSQL running locally (`localhost`)
- Node.js/npm (for assets)

### One-time setup

```bash
mix deps.get
mix ecto.create
mix ecto.migrate
mix test
```

### Run the app

```bash
mix phx.server
```

### Notes

- `mix setup` runs seeds. If your local DB already has seeded records (for example `testadmin@example.com`), seeds can fail due to duplicate data.
- If that happens, run setup commands individually (`deps.get`, `ecto.create`, `ecto.migrate`) and continue with `mix test`.

## Contributing

Please see [CONTRIBUTING.md](./CONTRIBUTING.md) for current contribution guidelines.
