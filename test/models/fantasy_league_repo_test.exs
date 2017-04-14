defmodule Ex338.FantasyLeagueRepoTest do
  use Ex338.ModelCase
  alias Ex338.{FantasyLeague, FantasyTeam, DraftPick}

  describe "by_league/2" do
    test "returns fantasy teams in a fantasy league" do
      league = insert(:fantasy_league)
      other_league = insert(:fantasy_league)
      _team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      _other_team = insert(:fantasy_team, team_name: "Another Team",
                                         fantasy_league: other_league)

      query = FantasyTeam |> FantasyLeague.by_league(league.id)
      query = from f in query, select: f.team_name

      assert Repo.all(query) == ~w(Brown)
    end

    test "returns draft picks in a fantasy league" do
      league = insert(:fantasy_league)
      other_league = insert(:fantasy_league)
      _pick = insert(:draft_pick, draft_position: 1.01, fantasy_league: league)
      _other_pick = insert(:draft_pick, draft_position: 2.01,
                                        fantasy_league: other_league)

      query = DraftPick |> FantasyLeague.by_league(league.id)
      query = from d in query, select: d.draft_position

      assert Repo.all(query) == [1.01]
    end
  end
end
