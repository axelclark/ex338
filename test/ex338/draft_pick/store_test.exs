defmodule Ex338.DraftPick.StoreTest do

  use Ex338.DataCase

  alias Ex338.{DraftPick.Store}

  describe "draft_player/2" do
    test "updates draft pick and inserts new roster position" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      pick = insert(:draft_pick, fantasy_league: league, fantasy_team: team)
      player = insert(:fantasy_player)
      params = %{"fantasy_player_id" => player.id}

      {:ok, %{draft_pick: draft_pick, roster_position: position}} =
        Store.draft_player(pick, params)

      assert draft_pick.fantasy_player_id == player.id
      assert position.fantasy_team_id == team.id
      assert position.fantasy_player_id == player.id
    end

    test "updates pending draft queues to unavailable" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      pick = insert(:draft_pick, fantasy_league: league, fantasy_team: team)
      player = insert(:fantasy_player)
      params = %{"fantasy_player_id" => player.id}

      team2 = insert(:fantasy_team, fantasy_league: league)
      insert(
        :draft_queue,
        fantasy_team: team2,
        fantasy_player: player,
        status: :pending
      )

      {:ok, %{unavailable_draft_queues: {1, [draft_queue]}}} =
        Store.draft_player(pick, params)

      assert draft_queue.status == :unavailable
    end

    test "does not update draft pick and returns error with invalid params" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      pick = insert(:draft_pick, fantasy_league: league, fantasy_team: team)
      params = %{"fantasy_player_id" => ""}

      {:error, :draft_pick, draft_pick_changeset, %{}} =
        Store.draft_player(pick, params)

      refute draft_pick_changeset.valid?
    end
  end

  describe "get_last_picks/1" do
    test "returns last 5 picks in descending order" do
      league = insert(:fantasy_league)
      insert(:submitted_pick, draft_position: 1.04, fantasy_league: league)
      insert(:submitted_pick, draft_position: 1.05, fantasy_league: league)
      insert(:submitted_pick, draft_position: 1.10, fantasy_league: league)
      insert(:submitted_pick, draft_position: 1.15, fantasy_league: league)
      insert(:submitted_pick, draft_position: 1.24, fantasy_league: league)
      insert(:draft_pick,     draft_position: 1.30, fantasy_league: league)

      results = Store.get_last_picks(league.id)

      assert Enum.map(results, &(&1.draft_position)) == [
        1.24, 1.15, 1.1, 1.05, 1.04
      ]
    end
  end

  describe "get_next_picks/1" do
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

      results = Store.get_next_picks(league.id)

      assert Enum.map(results, &(&1.draft_position)) == [
        1.05, 1.1, 1.15, 1.24, 1.3
      ]
    end
  end

  describe "get_picks_for_league/1" do
    test "returns draft picks in descending order" do
      league = insert(:fantasy_league)
      insert(:draft_pick, draft_position: 1.05, fantasy_league: league)
      insert(:draft_pick, draft_position: 1.04, fantasy_league: league)
      insert(:draft_pick, draft_position: 1.10, fantasy_league: league)

      other_league = insert(:fantasy_league)
      insert(:draft_pick, draft_position: 1.02, fantasy_league: other_league)

      picks = [first_pick|_] = Store.get_picks_for_league(league.id)

      assert Enum.map(picks, &(&1.draft_position)) == [1.04, 1.05, 1.1]
      assert first_pick.fantasy_league.id == league.id
    end
  end
end
