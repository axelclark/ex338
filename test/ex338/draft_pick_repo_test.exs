defmodule Ex338.DraftPickRepoTest do
  use Ex338.DataCase
  alias Ex338.{DraftPick}

  describe "by_league/2" do
    test "returns draft picks in a league" do
      league = insert(:fantasy_league)
      pick = insert(:draft_pick, fantasy_league: league)
      other_league = insert(:fantasy_league)
      _other_pick = insert(:draft_pick, fantasy_league: other_league)

      result =
        DraftPick
        |> DraftPick.by_league(league.id)
        |> Repo.one

      assert result.id == pick.id
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

      picks =
        DraftPick
        |> DraftPick.last_picks(league.id)
        |> Repo.all
        |> Enum.map(&(&1.draft_position))

      assert picks == [1.24, 1.15, 1.1, 1.05, 1.04]
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

      picks =
        DraftPick
        |> DraftPick.next_picks(league.id)
        |> Repo.all
        |> Enum.map(&(&1.draft_position))

      assert picks == [1.05, 1.1, 1.15, 1.24, 1.3]
    end
  end

  describe "ordered_by_position/1" do
    test "returns draft picks in descending order" do
      league = insert(:fantasy_league)
      insert(:draft_pick, draft_position: 1.05, fantasy_league: league)
      insert(:draft_pick, draft_position: 1.04, fantasy_league: league)
      insert(:draft_pick, draft_position: 1.10, fantasy_league: league)

      picks =
        DraftPick
        |> DraftPick.ordered_by_position
        |> Repo.all
        |> Enum.map(&(&1.draft_position))

      assert picks == [1.04, 1.05, 1.1]
    end
  end

  describe "preload_assocs/1" do
    test "returns draft pick with assocs preloaded" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      owner = insert(:owner, fantasy_team: team)
      sport = insert(:sports_league)
      player = insert(:fantasy_player, sports_league: sport)
      insert(
        :draft_pick,
        fantasy_league: league,
        fantasy_player: player,
        fantasy_team: team,
      )

      result = %{fantasy_team: %{owners: [owner_result]}} =
        DraftPick
        |> DraftPick.preload_assocs
        |> Repo.one

      assert owner_result.id == owner.id
      assert result.fantasy_player.sports_league.id == sport.id
      assert result.fantasy_league.id == league.id
    end
  end

  describe "reverse_ordered_by_position/1" do
    test "returns draft picks in ascending order" do
      league = insert(:fantasy_league)
      insert(:draft_pick, draft_position: 1.05, fantasy_league: league)
      insert(:draft_pick, draft_position: 1.04, fantasy_league: league)
      insert(:draft_pick, draft_position: 1.10, fantasy_league: league)

      picks =
        DraftPick
        |> DraftPick.reverse_ordered_by_position
        |> Repo.all
        |> Enum.map(&(&1.draft_position))

      assert picks == [1.1, 1.05, 1.04]
    end
  end
end
