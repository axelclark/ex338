# Script for populating the database. You can run it as:
#
#     mix run priv/repo/dev_seeds.exs
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

defmodule Ex338.DevSeeds do
  @moduledoc false

  alias Ex338.{
    RosterPosition,
    Repo,
    DraftPick,
    FantasyLeague,
    FantasyTeam,
    Waiver,
    Owner,
    ChampionshipResult,
    ChampionshipSlot,
    ChampWithEventsResult,
    CalendarAssistant,
    LeagueSport,
    Trade,
    TradeLineItem
  }

  def store_fantasy_leagues(row) do
    row = convert_fantasy_league_dates(row)
    changeset = FantasyLeague.changeset(%FantasyLeague{}, row)
    Repo.insert!(changeset)
  end

  defp convert_fantasy_league_dates(
         %{
           championships_start_at: start_at_days,
           championships_end_at: end_at_days
         } = fantasy_league
       ) do
    %{
      fantasy_league
      | championships_start_at: to_date(start_at_days),
        championships_end_at: to_date(end_at_days)
    }
  end

  defp to_date(days) do
    days
    |> String.to_integer()
    |> CalendarAssistant.days_from_now()
  end

  def store_league_sports(row) do
    changeset = LeagueSport.changeset(%LeagueSport{}, row)
    Repo.insert!(changeset)
  end

  def store_fantasy_teams(row) do
    changeset = FantasyTeam.changeset(%FantasyTeam{}, row)
    Repo.insert!(changeset)
  end

  def store_roster_positions(row) do
    changeset = RosterPosition.changeset(%RosterPosition{}, row)
    Repo.insert!(changeset)
  end

  def store_draft_picks(row) do
    row = Map.put(row, :drafted_at, DateTime.utc_now())
    changeset = DraftPick.changeset(%DraftPick{}, row)
    Repo.insert!(changeset)
  end

  def store_waivers(row) do
    row = convert_waiver_dates(row)
    changeset = Waiver.changeset(%Waiver{}, row)
    Repo.insert!(changeset)
  end

  defp convert_waiver_dates(
         %{
           process_at: process_days
         } = waiver
       ) do
    %{waiver | process_at: to_date(process_days)}
  end

  defp to_date(days) do
    days
    |> String.to_integer()
    |> CalendarAssistant.days_from_now()
  end

  def store_owners(row) do
    changeset = Owner.changeset(%Owner{}, row)
    Repo.insert!(changeset)
  end

  def store_championship_results(row) do
    changeset = ChampionshipResult.changeset(%ChampionshipResult{}, row)
    Repo.insert!(changeset)
  end

  def store_champ_with_events_results(row) do
    changeset = ChampWithEventsResult.changeset(%ChampWithEventsResult{}, row)
    Repo.insert!(changeset)
  end

  def store_championship_slots(row) do
    changeset = ChampionshipSlot.changeset(%ChampionshipSlot{}, row)
    Repo.insert!(changeset)
  end

  def store_trades(row) do
    changeset = Trade.changeset(%Trade{}, row)
    Repo.insert!(changeset)
  end

  def store_trade_line_items(row) do
    changeset = TradeLineItem.changeset(%TradeLineItem{}, row)
    Repo.insert!(changeset)
  end
end

File.stream!("priv/repo/csv_seed_data/fantasy_leagues.csv")
|> Stream.drop(1)
|> CSV.decode!(
  headers: [
    :fantasy_league_name,
    :year,
    :division,
    :championships_start_at,
    :championships_end_at
  ]
)
|> Enum.each(&Ex338.DevSeeds.store_fantasy_leagues/1)

File.stream!("priv/repo/csv_seed_data/league_sports.csv")
|> Stream.drop(1)
|> CSV.decode!(headers: [:fantasy_league_id, :sports_league_id])
|> Enum.each(&Ex338.DevSeeds.store_league_sports/1)

File.stream!("priv/repo/csv_seed_data/fantasy_teams.csv")
|> Stream.drop(1)
|> CSV.decode!(
  headers: [:team_name, :waiver_position, :dues_paid, :winnings_received, :fantasy_league_id]
)
|> Enum.each(&Ex338.DevSeeds.store_fantasy_teams/1)

File.stream!("priv/repo/csv_seed_data/roster_positions.csv")
|> Stream.drop(1)
|> CSV.decode!(headers: [:fantasy_team_id, :position, :fantasy_player_id, :status, :released_at])
|> Enum.each(&Ex338.DevSeeds.store_roster_positions/1)

File.stream!("priv/repo/csv_seed_data/draft_picks.csv")
|> Stream.drop(1)
|> CSV.decode!(
  headers: [:draft_position, :fantasy_league_id, :fantasy_team_id, :fantasy_player_id]
)
|> Enum.each(&Ex338.DevSeeds.store_draft_picks/1)

File.stream!("priv/repo/csv_seed_data/waivers.csv")
|> Stream.drop(1)
|> CSV.decode!(
  headers: [
    :fantasy_team_id,
    :add_fantasy_player_id,
    :drop_fantasy_player_id,
    :status,
    :process_at
  ]
)
|> Enum.each(&Ex338.DevSeeds.store_waivers/1)

File.stream!("priv/repo/csv_seed_data/owners.csv")
|> Stream.drop(1)
|> CSV.decode!(headers: [:fantasy_team_id, :user_id])
|> Enum.each(&Ex338.DevSeeds.store_owners/1)

File.stream!("priv/repo/csv_seed_data/championship_results.csv")
|> Stream.drop(1)
|> CSV.decode!(headers: [:championship_id, :fantasy_player_id, :rank, :points])
|> Enum.each(&Ex338.DevSeeds.store_championship_results/1)

File.stream!("priv/repo/csv_seed_data/champ_with_events_results.csv")
|> Stream.drop(1)
|> CSV.decode!(headers: [:championship_id, :fantasy_team_id, :rank, :points, :winnings])
|> Enum.each(&Ex338.DevSeeds.store_champ_with_events_results/1)

File.stream!("priv/repo/csv_seed_data/championship_slots.csv")
|> Stream.drop(1)
|> CSV.decode!(
  headers: [:roster_position_id, :championship_id, :slot, :team_id, :player_id, :position]
)
|> Enum.each(&Ex338.DevSeeds.store_championship_slots/1)

File.stream!("priv/repo/csv_seed_data/trades.csv")
|> Stream.drop(1)
|> CSV.decode!(headers: [:trade_id, :status, :additional_terms])
|> Enum.each(&Ex338.DevSeeds.store_trades/1)

File.stream!("priv/repo/csv_seed_data/trade_line_items.csv")
|> Stream.drop(1)
|> CSV.decode!(
  headers: [:line_item_id, :trade_id, :losing_team_id, :fantasy_player_id, :gaining_team_id]
)
|> Enum.each(&Ex338.DevSeeds.store_trade_line_items/1)
