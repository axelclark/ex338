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

defmodule Ex338.Seeds do
  @moduledoc false

  alias Ex338.{FantasyPlayer,SportsLeague, Repo, Championship, CalendarAssistant}

  def store_sports_leagues(row) do
    changeset = SportsLeague.changeset(%SportsLeague{}, row)
    Repo.insert!(changeset)
  end

  def store_championships(row) do
    row = convert_championship_dates(row)
    changeset = Championship.changeset(%Championship{}, row)
    Repo.insert!(changeset)
  end

  defp convert_championship_dates(%{
    trade_deadline_at: trade_days,
    waiver_deadline_at: waiver_days,
    championship_at: champ_days
  } = championship) do

    %{championship |
      trade_deadline_at: to_date(trade_days),
      waiver_deadline_at: to_date(waiver_days),
      championship_at: to_date(champ_days)}
  end

  defp to_date(days) do
     days
     |> String.to_integer
     |> CalendarAssistant.days_from_now
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
                          :sports_league_id, :overall_id, :in_season_draft,
                          :waiver_date, :trade_date, :champ_date])
  |> Enum.each(&Ex338.Seeds.store_championships/1)

File.stream!("priv/repo/csv_seed_data/fantasy_players.csv")
  |> Stream.drop(1)
  |> CSV.decode(headers: [:player_name, :sports_league_id, :draft_pick])
  |> Enum.each(&Ex338.Seeds.store_fantasy_players/1)
