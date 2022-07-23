defmodule Ex338.FantasyLeagueTest do
  @moduledoc false

  use Ex338.DataCase, async: true

  alias Ex338.{FantasyLeagues.FantasyLeague, FantasyTeams.FantasyTeam, DraftPicks.DraftPick}

  @valid_attrs %{fantasy_league_name: "2016 Div A", division: "A", year: 2016}
  @invalid_attrs %{}

  describe "changeset/2" do
    test "changeset with valid attributes" do
      changeset = FantasyLeague.changeset(%FantasyLeague{}, @valid_attrs)
      assert changeset.valid?
    end

    test "changeset with invalid attributes" do
      changeset = FantasyLeague.changeset(%FantasyLeague{}, @invalid_attrs)
      refute changeset.valid?
    end
  end

  describe "leagues_by_status/2" do
    test "returns fantasy leagues based on navbar_display" do
      archived_league = insert(:fantasy_league, navbar_display: "archived")
      insert(:fantasy_league, navbar_display: "primary")

      result =
        FantasyLeague
        |> FantasyLeague.leagues_by_status("archived")
        |> Repo.one()

      assert result.id == archived_league.id
    end
  end

  describe "by_league/2" do
    test "returns fantasy teams in a fantasy league" do
      league = insert(:fantasy_league)
      other_league = insert(:fantasy_league)
      _team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)

      _other_team =
        insert(
          :fantasy_team,
          team_name: "Another Team",
          fantasy_league: other_league
        )

      query = FantasyTeam |> FantasyLeague.by_league(league.id)
      query = from(f in query, select: f.team_name)

      assert Repo.all(query) == ~w(Brown)
    end

    test "returns draft picks in a fantasy league" do
      league = insert(:fantasy_league)
      other_league = insert(:fantasy_league)
      _pick = insert(:draft_pick, draft_position: 1.01, fantasy_league: league)

      _other_pick =
        insert(
          :draft_pick,
          draft_position: 2.01,
          fantasy_league: other_league
        )

      query = DraftPick |> FantasyLeague.by_league(league.id)
      query = from(d in query, select: d.draft_position)

      assert Repo.all(query) == [1.01]
    end
  end

  describe "sort_by_division/1" do
    test "returns fantasy leagues alphabetically by division" do
      insert(:fantasy_league, division: "B")
      insert(:fantasy_league, division: "C")
      insert(:fantasy_league, division: "A")

      results =
        FantasyLeague
        |> FantasyLeague.sort_by_division()
        |> Repo.all()

      assert Enum.map(results, & &1.division) == ["A", "B", "C"]
    end
  end

  describe "sort_by_draft_method/1" do
    test "returns fantasy leagues alphabetically by draft method" do
      insert(:fantasy_league, draft_method: :redraft)
      insert(:fantasy_league, draft_method: :keeper)
      insert(:fantasy_league, draft_method: :redraft)

      results =
        FantasyLeague
        |> FantasyLeague.sort_by_draft_method()
        |> Repo.all()

      assert Enum.map(results, & &1.draft_method) == [:keeper, :redraft, :redraft]
    end
  end

  describe "sort_most_recent/1" do
    test "returns fantasy leagues with most recent first" do
      insert(:fantasy_league, year: 2018)
      insert(:fantasy_league, year: 2016)
      insert(:fantasy_league, year: 2017)

      results =
        FantasyLeague
        |> FantasyLeague.sort_most_recent()
        |> Repo.all()

      assert Enum.map(results, & &1.year) == [2018, 2017, 2016]
    end
  end
end
