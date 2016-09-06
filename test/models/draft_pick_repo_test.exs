defmodule Ex338.DraftPickRepoTest do
  use Ex338.ModelCase
  alias Ex338.{DraftPick}

  describe "ordered_by_position/1" do
    test "returns draft picks in descending order" do
      league = insert(:fantasy_league)
      insert(:draft_pick, draft_position: 1.05, fantasy_league: league)
      insert(:draft_pick, draft_position: 1.04, fantasy_league: league)
      insert(:draft_pick, draft_position: 1.10, fantasy_league: league)

      query = DraftPick |> DraftPick.ordered_by_position
      query = from d in query, select: d.draft_position
      picks = query
              |> Repo.all
              |> Enum.map(&(Float.to_string(&1)))

      assert picks == ~w(1.04 1.05 1.1)
    end
  end

  describe "reverse_ordered_by_position/1" do
    test "returns draft picks in ascending order" do
      league = insert(:fantasy_league)
      insert(:draft_pick, draft_position: 1.05, fantasy_league: league)
      insert(:draft_pick, draft_position: 1.04, fantasy_league: league)
      insert(:draft_pick, draft_position: 1.10, fantasy_league: league)

      query = DraftPick |> DraftPick.reverse_ordered_by_position
      query = from d in query, select: d.draft_position
      picks = query
              |> Repo.all
              |> Enum.map(&(Float.to_string(&1)))

      assert picks == ~w(1.1 1.05 1.04)
    end
  end

  describe "next_picks/2" do
    test "returns next 5 picks in descending order" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team)
      player = insert(:fantasy_player)
      insert(:draft_pick, draft_position: 1.04, fantasy_league: league,
                          fantasy_team: team, fantasy_player: player)
      insert(:draft_pick, draft_position: 1.05, fantasy_league: league)
      insert(:draft_pick, draft_position: 1.10, fantasy_league: league)
      insert(:draft_pick, draft_position: 1.15, fantasy_league: league)
      insert(:draft_pick, draft_position: 1.24, fantasy_league: league)
      insert(:draft_pick, draft_position: 1.30, fantasy_league: league)

      query = DraftPick |> DraftPick.next_picks(league.id)
      picks = query
              |> Repo.all
              |> Enum.map(&(&1.draft_position))

      assert picks == [1.05, 1.1, 1.15, 1.24, 1.3]
    end
  end

  describe "last_picks/2" do
    test "returns last 5 picks in descending order" do
      league = insert(:fantasy_league)
      insert(:submitted_pick, draft_position: 1.04, fantasy_league: league)
      insert(:submitted_pick, draft_position: 1.05, fantasy_league: league)
      insert(:submitted_pick, draft_position: 1.10, fantasy_league: league)
      insert(:submitted_pick, draft_position: 1.15, fantasy_league: league)
      insert(:submitted_pick, draft_position: 1.24, fantasy_league: league)
      insert(:draft_pick,     draft_position: 1.30, fantasy_league: league)

      query = DraftPick |> DraftPick.last_picks(league.id)
      picks = query
              |> Repo.all
              |> Enum.map(&(&1.draft_position))

      assert picks == [1.24, 1.15, 1.1, 1.05, 1.04]
    end
  end
end
