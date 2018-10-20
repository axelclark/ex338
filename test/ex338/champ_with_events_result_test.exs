defmodule Ex338.ChampWithEventsResultTest do
  use Ex338.DataCase

  alias Ex338.ChampWithEventsResult

  describe "before_date_in_year/2" do
    test "returns all championships before a date in a year" do
      {:ok, last_year, _} = DateTime.from_iso8601("2017-01-23T23:50:07Z")
      {:ok, may_date, _} = DateTime.from_iso8601("2018-05-23T23:50:07Z")
      {:ok, oct_date, _} = DateTime.from_iso8601("2018-10-23T23:50:07Z")
      {:ok, jun_date, _} = DateTime.from_iso8601("2018-06-01T00:00:00Z")

      old_champ = insert(:championship, year: 2017, championship_at: last_year)
      may_champ = insert(:championship, year: 2018, championship_at: may_date)
      oct_champ = insert(:championship, year: 2018, championship_at: oct_date)

      _old_result = insert(:champ_with_events_result, championship: old_champ)
      may_result = insert(:champ_with_events_result, championship: may_champ)
      _oct_result = insert(:champ_with_events_result, championship: oct_champ)

      result =
        ChampWithEventsResult
        |> ChampWithEventsResult.before_date_in_year(jun_date)
        |> Repo.one()

      assert result.id == may_result.id
    end
  end

  describe "changeset/2" do
    @valid_attrs %{
      points: "120.5",
      rank: 42,
      winnings: "120.5",
      fantasy_team_id: 1,
      championship_id: 1
    }
    test "changeset with valid attributes" do
      changeset = ChampWithEventsResult.changeset(%ChampWithEventsResult{}, @valid_attrs)

      assert changeset.valid?
    end

    @invalid_attrs %{}
    test "changeset with invalid attributes" do
      changeset = ChampWithEventsResult.changeset(%ChampWithEventsResult{}, @invalid_attrs)

      refute changeset.valid?
    end
  end

  describe "order_by_rank/1" do
    test "returns championship results in order by rank" do
      insert(:champ_with_events_result, rank: 1)
      insert(:champ_with_events_result, rank: 4)
      insert(:champ_with_events_result, rank: 3)
      insert(:champ_with_events_result, rank: 2)

      result =
        ChampWithEventsResult
        |> ChampWithEventsResult.order_by_rank()
        |> select([c], c.rank)
        |> Repo.all()

      assert result == [1, 2, 3, 4]
    end
  end

  describe "preload_assocs/1" do
    test "preloads all assocs" do
      team_a = insert(:fantasy_team)
      championship = insert(:championship)

      insert(
        :champ_with_events_result,
        fantasy_team: team_a,
        championship: championship
      )

      result =
        ChampWithEventsResult
        |> ChampWithEventsResult.preload_assocs()
        |> Repo.one()

      assert result.fantasy_team.id == team_a.id
      assert result.championship.id == championship.id
    end
  end

  describe "preload_assocs_by_league/2" do
    test "preloads all assocs for a league" do
      f_league_a = insert(:fantasy_league)
      f_league_b = insert(:fantasy_league)
      team_a = insert(:fantasy_team, fantasy_league: f_league_a)
      team_b = insert(:fantasy_team, fantasy_league: f_league_b)
      championship = insert(:championship)

      insert(
        :champ_with_events_result,
        fantasy_team: team_a,
        championship: championship
      )

      insert(
        :champ_with_events_result,
        fantasy_team: team_b,
        championship: championship
      )

      result =
        ChampWithEventsResult
        |> ChampWithEventsResult.preload_assocs_by_league(f_league_a.id)
        |> Repo.one()

      assert result.fantasy_team.id == team_a.id
    end
  end

  describe "preload_ordered_assocs_by_league/2" do
    test "preloads assocs for league in order" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      championship = insert(:championship)

      insert(
        :champ_with_events_result,
        fantasy_team: team,
        championship: championship
      )

      result =
        ChampWithEventsResult
        |> ChampWithEventsResult.preload_ordered_assocs_by_league(league.id)
        |> Repo.one()

      assert result.fantasy_team.id == team.id
    end
  end
end
