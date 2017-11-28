defmodule Ex338.ChampWithEventsResultTest do
  use Ex338.DataCase

  alias Ex338.ChampWithEventsResult

  describe "changeset/2" do
    @valid_attrs %{points: "120.5", rank: 42, winnings: "120.5",
     fantasy_team_id: 1, championship_id: 1}
   test "changeset with valid attributes" do
     changeset =
       ChampWithEventsResult.changeset(%ChampWithEventsResult{}, @valid_attrs)

       assert changeset.valid?
   end

   @invalid_attrs %{}
   test "changeset with invalid attributes" do
     changeset =
       ChampWithEventsResult.changeset(%ChampWithEventsResult{}, @invalid_attrs)

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
        |> ChampWithEventsResult.order_by_rank
        |> select([c], c.rank)
        |> Repo.all

      assert result == [1, 2, 3, 4]
    end
  end

  describe "preload_assocs_by_league/2" do
    test "preloads all assocs for a league" do
      f_league_a = insert(:fantasy_league)
      f_league_b = insert(:fantasy_league)
      team_a = insert(:fantasy_team, fantasy_league: f_league_a)
      team_b = insert(:fantasy_team, fantasy_league: f_league_b)
      championship = insert(:championship)
      insert(:champ_with_events_result, fantasy_team: team_a,
        championship: championship)
      insert(:champ_with_events_result, fantasy_team: team_b,
        championship: championship)

      result =
        ChampWithEventsResult
        |> ChampWithEventsResult.preload_assocs_by_league(f_league_a.id)
        |> Repo.one

      assert result.fantasy_team.id == team_a.id
    end
  end

  describe "preload_ordered_assocs_by_league/2" do
    test "preloads assocs for league in order" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      championship = insert(:championship)
      insert(:champ_with_events_result, fantasy_team: team,
        championship: championship)

      result =
        ChampWithEventsResult
        |> ChampWithEventsResult.preload_ordered_assocs_by_league(league.id)
        |> Repo.one

      assert result.fantasy_team.id == team.id
    end
  end
end
