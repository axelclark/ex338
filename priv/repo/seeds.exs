# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Ex338.Repo.insert!(%Ex338.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
#
# To substitue hidden characters in VIM %s/<ctr>v<ctrl>m/\r/g

alias Ex338.{FantasyPlayer,SportsLeague, Repo, Championship}

defmodule Ex338.Seeds do

  def store_sports_leagues(row) do
    changeset = SportsLeague.changeset(%SportsLeague{}, row)
    Repo.insert!(changeset)
  end

  def store_championships(row) do
    changeset = Championship.changeset(%Championship{}, row)
    Repo.insert!(changeset)
  end

  def store_fantasy_players(row) do
    changeset = FantasyPlayer.changeset(%FantasyPlayer{}, row)
    Repo.insert!(changeset)
  end
end

File.stream!("priv/repo/csv_seed_data/sports_leagues.csv")
  |> Stream.drop(1)
  |> CSV.decode(headers: [:league_name, :abbrev])
  |> Enum.each(&Ex338.Seeds.store_sports_leagues/1)

File.stream!("priv/repo/csv_seed_data/championships.csv")
  |> Stream.drop(1)
  |> CSV.decode(headers: [:title, :category,  :waiver_deadline_at,
                          :trade_deadline_at, :championship_at,
                          :sports_league_id, :overall_id])
  |> Enum.each(&Ex338.Seeds.store_championships/1)

File.stream!("priv/repo/csv_seed_data/fantasy_players.csv")
  |> Stream.drop(1)
  |> CSV.decode(headers: [:player_name, :sports_league_id])
  |> Enum.each(&Ex338.Seeds.store_fantasy_players/1)
