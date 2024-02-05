# Ex338

A web application to manage the 338 Challenge Fantasy League built using [Elixir](https://elixir-lang.org/)
and [Phoenix](http://www.phoenixframework.org/).  The 338 Challenge is a
fantasy sports league where you pick teams instead of players and get points
when your team wins its league championship.

The draft, waivers, and trades are accomplished through the website.  The league
is set up to have multiple divisions (with relegation).

### Home Page
![Home Page](/README_assets/ex338_home_screen.png?raw=true "Home Page")

<br />
<br />

### List of Players
![Players Page](/README_assets/ex338_fantasy_players_screen.png?raw=true "Players")

## Setup

To start the app:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Add db seeds with `mix run priv/repo/seeds.exs`
  * Add user seeds with `mix run priv/repo/user_seeds.exs`
  * Add development seeds with `mix run priv/repo/dev_seeds.exs`
  * Install Node.js dependencies with `cd assets && npm install && cd -`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Contributing

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :D
