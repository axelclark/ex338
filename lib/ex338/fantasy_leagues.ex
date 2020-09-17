defmodule Ex338.FantasyLeagues do
  @moduledoc false

  alias Ex338.{
    DraftPicks,
    FantasyLeagues.FantasyLeague,
    FantasyLeagues.HistoricalRecord,
    FantasyLeagues.HistoricalWinning,
    FantasyTeams,
    Repo
  }

  def create_future_picks_for_league(league_id, draft_rounds) do
    league_id
    |> FantasyTeams.list_teams_for_league()
    |> DraftPicks.create_future_picks(draft_rounds)
  end

  def get(id) do
    Repo.get(FantasyLeague, id)
  end

  def get_leagues_by_status(status) do
    Enum.map(list_leagues_by_status(status), &load_team_standings_data/1)
  end

  def list_all_winnings() do
    HistoricalWinning
    |> HistoricalWinning.order_by_amount()
    |> Repo.all()
  end

  def list_current_all_time_records() do
    HistoricalRecord
    |> HistoricalRecord.all_time_records()
    |> HistoricalRecord.current_records()
    |> HistoricalRecord.sorted_by_order()
    |> Repo.all()
  end

  def list_current_season_records() do
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
    |> FantasyLeague.sort_by_division()
    |> Repo.all()
  end

  def load_team_standings_data(league) do
    teams = FantasyTeams.find_all_for_standings(league)
    %{league | fantasy_teams: teams}
  end

  @doc """
  Returns the list of fantasy_leagues.

  ## Examples

      iex> list_fantasy_leagues()
      [%FantasyLeague{}, ...]

  """
  def list_fantasy_leagues() do
    FantasyLeague
    |> FantasyLeague.sort_most_recent()
    |> FantasyLeague.sort_by_division()
    |> Repo.all()
  end

  @doc """
  Gets a single fantasy_league.

  Raises if the Fantasy league does not exist.

  ## Examples

      iex> get_fantasy_league!(123)
      %FantasyLeague{}

  """
  def get_fantasy_league!(id), do: Repo.get!(FantasyLeague, id)

  @doc """
  Creates a fantasy_league.

  ## Examples

      iex> create_fantasy_league(%{field: value})
      {:ok, %FantasyLeague{}}

      iex> create_fantasy_league(%{field: bad_value})
      {:error, ...}

  """
  def create_fantasy_league(attrs \\ %{}) do
    %FantasyLeague{}
    |> FantasyLeague.changeset(attrs)
    |> Repo.insert!()
  end

  @doc """
  Updates a fantasy_league.

  ## Examples

      iex> update_fantasy_league(fantasy_league, %{field: new_value})
      {:ok, %FantasyLeague{}}

      iex> update_fantasy_league(fantasy_league, %{field: bad_value})
      {:error, ...}

  """
  def update_fantasy_league(%FantasyLeague{} = fantasy_league, attrs) do
    fantasy_league
    |> FantasyLeague.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a FantasyLeague.

  ## Examples

      iex> delete_fantasy_league(fantasy_league)
      {:ok, %FantasyLeague{}}

      iex> delete_fantasy_league(fantasy_league)
      {:error, ...}

  """
  def delete_fantasy_league(%FantasyLeague{} = fantasy_league) do
    Repo.delete!(fantasy_league)
  end

  @doc """
  Returns a data structure for tracking fantasy_league changes.

  ## Examples

      iex> change_fantasy_league(fantasy_league)
      %Todo{...}

  """
  def change_fantasy_league(%FantasyLeague{} = fantasy_league, attrs \\ %{}) do
    FantasyLeague.changeset(fantasy_league, attrs)
  end
end
