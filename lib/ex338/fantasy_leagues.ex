defmodule Ex338.FantasyLeagues do
  @moduledoc false

  import Ecto.Query

  alias Ex338.DraftPicks
  alias Ex338.FantasyLeagues.FantasyLeague
  alias Ex338.FantasyLeagues.FantasyLeagueDraft
  alias Ex338.FantasyLeagues.HistoricalRecord
  alias Ex338.FantasyLeagues.HistoricalWinning
  alias Ex338.FantasyTeams
  alias Ex338.Repo

  def change_fantasy_league(%FantasyLeague{} = fantasy_league, attrs \\ %{}) do
    FantasyLeague.changeset(fantasy_league, attrs)
  end

  def create_future_picks_for_league(league_id, draft_rounds) do
    league_id
    |> FantasyTeams.list_teams_for_league()
    |> DraftPicks.create_future_picks(draft_rounds)
  end

  def get(id) do
    Repo.get(FantasyLeague, id)
  end

  def get_fantasy_league!(id), do: Repo.get!(FantasyLeague, id)

  def get_leagues_by_status(status) do
    Enum.map(list_leagues_by_status(status), &load_team_standings_data/1)
  end

  def list_all_winnings do
    HistoricalWinning
    |> HistoricalWinning.order_by_amount()
    |> Repo.all()
  end

  def list_current_all_time_records do
    HistoricalRecord
    |> HistoricalRecord.all_time_records()
    |> HistoricalRecord.current_records()
    |> HistoricalRecord.sorted_by_order()
    |> Repo.all()
  end

  def list_current_season_records do
    HistoricalRecord
    |> HistoricalRecord.season_records()
    |> HistoricalRecord.current_records()
    |> HistoricalRecord.sorted_by_order()
    |> Repo.all()
  end

  def list_leagues_by_status(status) do
    FantasyLeague
    |> FantasyLeague.leagues_by_status(status)
    |> FantasyLeague.sort_most_recent()
    |> FantasyLeague.sort_by_draft_method()
    |> FantasyLeague.sort_by_division()
    |> Repo.all()
  end

  def list_fantasy_leagues do
    FantasyLeague
    |> FantasyLeague.sort_most_recent()
    |> FantasyLeague.sort_by_draft_method()
    |> FantasyLeague.sort_by_division()
    |> Repo.all()
  end

  def load_team_standings_data(league) do
    teams = FantasyTeams.find_all_for_standings(league)
    %{league | fantasy_teams: teams}
  end

  def options_for_navbar_display do
    Enum.filter(FantasyLeagueNavbarDisplayEnum.__valid_values__(), &is_atom(&1))
  end

  def options_for_draft_method do
    Enum.filter(FantasyLeagueDraftMethodEnum.__valid_values__(), &is_atom(&1))
  end

  def update_fantasy_league(%FantasyLeague{} = fantasy_league, attrs) do
    fantasy_league
    |> FantasyLeague.changeset(attrs)
    |> Repo.update()
  end

  def format_leagues_for_select(leagues) do
    Enum.map(leagues, fn league ->
      {league.fantasy_league_name, league.id}
    end)
  end

  def create_fantasy_league_draft!(attrs) do
    %FantasyLeagueDraft{}
    |> FantasyLeagueDraft.changeset(attrs)
    |> Repo.insert!()
  end

  def get_draft_by_league_and_championship(fantasy_league, championship) do
    query =
      from(d in FantasyLeagueDraft,
        where:
          d.fantasy_league_id == ^fantasy_league.id and d.championship_id == ^championship.id,
        preload: [chat: [messages: :user]]
      )

    Repo.one(query)
  end
end
