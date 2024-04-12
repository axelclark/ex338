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

  alias Ex338.CalendarAssistant
  alias Ex338.Championships.Championship
  alias Ex338.Championships.ChampionshipResult
  alias Ex338.Championships.ChampionshipSlot
  alias Ex338.Championships.ChampWithEventsResult
  alias Ex338.DraftPicks.DraftPick
  alias Ex338.FantasyLeagues.FantasyLeague
  alias Ex338.FantasyLeagues.LeagueSport
  alias Ex338.FantasyPlayers.FantasyPlayer
  alias Ex338.FantasyPlayers.SportsLeague
  alias Ex338.FantasyTeams.FantasyTeam
  alias Ex338.FantasyTeams.Owner
  alias Ex338.Repo
  alias Ex338.RosterPositions.RosterPosition
  alias Ex338.Trades.Trade
  alias Ex338.Trades.TradeLineItem
  alias Ex338.Waivers.Waiver

  def store_sports_leagues(row) do
    changeset = SportsLeague.changeset(%SportsLeague{}, row)
    Repo.insert!(changeset)
  end

  def store_championships(row) do
    row = convert_championship_dates(row)
    changeset = Championship.changeset(%Championship{}, row)
    Repo.insert!(changeset)
  end

  defp convert_championship_dates(
         %{
           trade_deadline_at: trade_days,
           waiver_deadline_at: waiver_days,
           championship_at: champ_days,
           draft_starts_at: draft_days
         } = championship
       ) do
    %{
      championship
      | trade_deadline_at: to_date(trade_days),
        waiver_deadline_at: to_date(waiver_days),
        championship_at: to_date(champ_days),
        draft_starts_at: to_date(draft_days)
    }
  end

  defp to_date(days) do
    case Integer.parse(days) do
      {days, _remainder} ->
        CalendarAssistant.days_from_now(days)

      :error ->
        nil
    end
  end

  def store_fantasy_players(row) do
    {:ok, start, _} = DateTime.from_iso8601("2017-01-01T00:00:00Z")
    row = Map.put(row, :available_starting_at, start)

    changeset = FantasyPlayer.changeset(%FantasyPlayer{}, row)
    Repo.insert!(changeset)
  end

  def store_fantasy_leagues(row) do
    row = convert_fantasy_league_dates(row)
    changeset = FantasyLeague.changeset(%FantasyLeague{}, row)
    Repo.insert!(changeset)
  end

  defp convert_fantasy_league_dates(
         %{championships_start_at: start_at_days, championships_end_at: end_at_days} =
           fantasy_league
       ) do
    %{
      fantasy_league
      | championships_start_at: to_date(start_at_days),
        championships_end_at: to_date(end_at_days)
    }
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
    row =
      if row.fantasy_player_id == "" do
        row
      else
        Map.put(row, :drafted_at, DateTime.utc_now())
      end

    changeset = DraftPick.changeset(%DraftPick{}, row)
    Repo.insert!(changeset)
  end

  def store_waivers(row) do
    row = convert_waiver_dates(row)
    changeset = Waiver.changeset(%Waiver{}, row)
    Repo.insert!(changeset)
  end

  defp convert_waiver_dates(%{process_at: process_days} = waiver) do
    %{waiver | process_at: to_date(process_days)}
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

"priv/repo/csv_seed_data/sports_leagues.csv"
|> File.stream!()
|> Stream.drop(1)
|> CSV.decode!(headers: [:league_name, :abbrev])
|> Enum.each(&Ex338.Seeds.store_sports_leagues/1)

"priv/repo/csv_seed_data/championships.csv"
|> File.stream!()
|> Stream.drop(1)
|> CSV.decode!(
  headers: [
    :title,
    :category,
    :waiver_deadline_at,
    :trade_deadline_at,
    :draft_starts_at,
    :championship_at,
    :sports_league_id,
    :overall_id,
    :in_season_draft,
    :year,
    :waiver_date,
    :trade_date,
    :champ_date
  ]
)
|> Enum.each(&Ex338.Seeds.store_championships/1)

"priv/repo/csv_seed_data/fantasy_players.csv"
|> File.stream!()
|> Stream.drop(1)
|> CSV.decode!(headers: [:player_name, :sports_league_id, :draft_pick])
|> Enum.each(&Ex338.Seeds.store_fantasy_players/1)

%Ex338.Accounts.User{}
|> Ex338.Accounts.User.registration_fixture_changeset(%{
  name: "Test Admin",
  email: "testadmin@example.com",
  password: "password",
  admin: true
})
|> Ex338.Repo.insert!()

%Ex338.Accounts.User{}
|> Ex338.Accounts.User.registration_fixture_changeset(%{
  name: "Test User",
  email: "testuser@example.com",
  password: "password",
  admin: false
})
|> Ex338.Repo.insert!()

"priv/repo/csv_seed_data/fantasy_leagues.csv"
|> File.stream!()
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
|> Enum.each(&Ex338.Seeds.store_fantasy_leagues/1)

"priv/repo/csv_seed_data/league_sports.csv"
|> File.stream!()
|> Stream.drop(1)
|> CSV.decode!(headers: [:fantasy_league_id, :sports_league_id])
|> Enum.each(&Ex338.Seeds.store_league_sports/1)

"priv/repo/csv_seed_data/fantasy_teams.csv"
|> File.stream!()
|> Stream.drop(1)
|> CSV.decode!(
  headers: [:team_name, :waiver_position, :dues_paid, :winnings_received, :fantasy_league_id]
)
|> Enum.each(&Ex338.Seeds.store_fantasy_teams/1)

"priv/repo/csv_seed_data/roster_positions.csv"
|> File.stream!()
|> Stream.drop(1)
|> CSV.decode!(headers: [:fantasy_team_id, :position, :fantasy_player_id, :status, :released_at])
|> Enum.each(&Ex338.Seeds.store_roster_positions/1)

"priv/repo/csv_seed_data/draft_picks.csv"
|> File.stream!()
|> Stream.drop(1)
|> CSV.decode!(
  headers: [:draft_position, :fantasy_league_id, :fantasy_team_id, :fantasy_player_id]
)
|> Enum.each(&Ex338.Seeds.store_draft_picks/1)

"priv/repo/csv_seed_data/waivers.csv"
|> File.stream!()
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
|> Enum.each(&Ex338.Seeds.store_waivers/1)

"priv/repo/csv_seed_data/owners.csv"
|> File.stream!()
|> Stream.drop(1)
|> CSV.decode!(headers: [:fantasy_team_id, :user_id])
|> Enum.each(&Ex338.Seeds.store_owners/1)

"priv/repo/csv_seed_data/championship_results.csv"
|> File.stream!()
|> Stream.drop(1)
|> CSV.decode!(headers: [:championship_id, :fantasy_player_id, :rank, :points])
|> Enum.each(&Ex338.Seeds.store_championship_results/1)

"priv/repo/csv_seed_data/champ_with_events_results.csv"
|> File.stream!()
|> Stream.drop(1)
|> CSV.decode!(headers: [:championship_id, :fantasy_team_id, :rank, :points, :winnings])
|> Enum.each(&Ex338.Seeds.store_champ_with_events_results/1)

"priv/repo/csv_seed_data/championship_slots.csv"
|> File.stream!()
|> Stream.drop(1)
|> CSV.decode!(
  headers: [:roster_position_id, :championship_id, :slot, :team_id, :player_id, :position]
)
|> Enum.each(&Ex338.Seeds.store_championship_slots/1)

"priv/repo/csv_seed_data/trades.csv"
|> File.stream!()
|> Stream.drop(1)
|> CSV.decode!(headers: [:trade_id, :status, :additional_terms])
|> Enum.each(&Ex338.Seeds.store_trades/1)

"priv/repo/csv_seed_data/trade_line_items.csv"
|> File.stream!()
|> Stream.drop(1)
|> CSV.decode!(
  headers: [:line_item_id, :trade_id, :losing_team_id, :fantasy_player_id, :gaining_team_id]
)
|> Enum.each(&Ex338.Seeds.store_trade_line_items/1)
