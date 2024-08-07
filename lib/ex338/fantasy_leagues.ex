defmodule Ex338.FantasyLeagues do
  @moduledoc false

  import Ecto.Query

  alias Ex338.Championships.Championship
  alias Ex338.Chats
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

  def create_draft_chat_for_championship(
        %FantasyLeague{} = fantasy_league,
        %Championship{} = championship
      ) do
    room_name = "#{fantasy_league.fantasy_league_name} #{championship.title}"

    Repo.transact(fn ->
      with {:ok, chat} <- Chats.create_chat(%{room_name: room_name}),
           {:ok, fantasy_league_championship} <-
             create_fantasy_league_draft(%{
               fantasy_league_id: fantasy_league.id,
               chat_id: chat.id,
               championship_id: championship.id
             }) do
        {:ok, chat: chat, fantasy_league_championship: fantasy_league_championship}
      end
    end)
  end

  def create_draft_chat_for_league(%FantasyLeague{} = fantasy_league) do
    room_name = "#{fantasy_league.fantasy_league_name}"

    Repo.transact(fn ->
      with {:ok, chat} <- Chats.create_chat(%{room_name: room_name}),
           {:ok, fantasy_league_draft} <-
             create_fantasy_league_draft(%{
               fantasy_league_id: fantasy_league.id,
               chat_id: chat.id
             }) do
        {:ok, chat: chat, fantasy_league_draft: fantasy_league_draft}
      end
    end)
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

  def create_fantasy_league_draft(attrs) do
    %FantasyLeagueDraft{}
    |> FantasyLeagueDraft.changeset(attrs)
    |> Repo.insert()
  end

  def get_draft_by_league_and_championship(
        %FantasyLeague{} = fantasy_league,
        %Championship{} = championship
      ) do
    query =
      from(d in FantasyLeagueDraft,
        where:
          d.fantasy_league_id == ^fantasy_league.id and d.championship_id == ^championship.id,
        preload: [chat: [messages: [user: [owners: :fantasy_team]]]]
      )

    Repo.one(query)
  end

  def get_draft_by_league(%FantasyLeague{} = fantasy_league) do
    query =
      from(d in FantasyLeagueDraft,
        where: d.fantasy_league_id == ^fantasy_league.id and is_nil(d.championship_id),
        preload: [chat: [messages: [user: [owners: :fantasy_team]]]]
      )

    Repo.one(query)
  end

  def get_draft_with_chat_by_league_and_championship(fantasy_league_id, championship_id) do
    query =
      from(d in FantasyLeagueDraft,
        where: d.fantasy_league_id == ^fantasy_league_id,
        where: d.championship_id == ^championship_id,
        where: not is_nil(d.chat_id)
      )

    Repo.one(query)
  end

  def get_draft_with_chat_by_league(fantasy_league_id) do
    query =
      from(d in FantasyLeagueDraft,
        where: d.fantasy_league_id == ^fantasy_league_id and is_nil(d.championship_id),
        where: not is_nil(d.chat_id)
      )

    Repo.one(query)
  end
end
