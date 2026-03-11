# Ex338

[![CI](https://github.com/axelclark/ex338/actions/workflows/main.yml/badge.svg)](https://github.com/axelclark/ex338/actions/workflows/main.yml)

A web application to manage the [338 Challenge](https://the338challenge.com) Fantasy League built with [Elixir](https://elixir-lang.org/) and [Phoenix](https://www.phoenixframework.org/).

The 338 Challenge is a fantasy sports league where you pick teams instead of players and earn points when your team wins its league championship. The draft, waivers, and trades are all managed through the website. The league supports multiple divisions with relegation.

### Home Page

![Home Page](/README_assets/ex338_home_screen.png?raw=true "Home Page")

### Players List

![Players Page](/README_assets/ex338_fantasy_players_screen.png?raw=true "Players")

## Tech Stack

- **Language:** [Elixir](https://elixir-lang.org/) 1.18 / OTP 27
- **Framework:** [Phoenix](https://www.phoenixframework.org/) with LiveView
- **Database:** PostgreSQL
- **Hosting:** [Render](https://render.com)

## Setup

To start your Phoenix server:

1. Run `mix setup` to install and setup dependencies
2. Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`
3. Visit [`localhost:4000`](http://localhost:4000) from your browser

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
