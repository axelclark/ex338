defmodule Ex338.DraftQueuesTest do
  use Ex338.DataCase, async: true

  alias Ex338.DraftQueues
  alias Ex338.DraftQueues.DraftQueue

  describe "create_draft_queue" do
    test "creates a draft queue with valid attributes" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      sport = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: sport)
      insert(:championship, sports_league: sport)
      player = insert(:fantasy_player, sports_league: sport)
      attrs = %{"fantasy_team_id" => team.id, "fantasy_player_id" => player.id}

      {:ok, result} = DraftQueues.create_draft_queue(attrs)

      assert result.fantasy_team_id == team.id
      assert result.fantasy_player_id == player.id
      assert result.status == "pending"
      assert result.order == 1
    end

    test "returns an error with invalid attributes" do
      assert {:error, %Ecto.Changeset{}} = DraftQueues.create_draft_queue(%{})
    end
  end

  describe "get_draft_queue!/1" do
    test "returns a draft queue" do
      queue = insert(:draft_queue)
      assert DraftQueues.get_draft_queue!(queue.id).id == queue.id
    end
  end

  describe "get_league_queues/1" do
    test "returns pending draft queues for a league" do
      sport = insert(:sports_league)
      player = insert(:fantasy_player, sports_league: sport)

      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      team2 = insert(:fantasy_team, fantasy_league: league)
      other_league = insert(:fantasy_league)
      other_team = insert(:fantasy_team, fantasy_league: other_league)

      insert(:draft_queue, fantasy_player: player, fantasy_team: team)
      insert(:draft_queue, fantasy_player: player, fantasy_team: team2)
      insert(:draft_queue, fantasy_player: player, fantasy_team: other_team)

      result = DraftQueues.get_league_queues(league.id)

      assert Enum.count(result) == 2
    end
  end

  describe "get_top_queue/1" do
    test "returns pending draft queues for a team and sport" do
      sport = insert(:sports_league)
      sport2 = insert(:sports_league)

      player = insert(:fantasy_player, sports_league: sport)
      player2 = insert(:fantasy_player, sports_league: sport2)
      player3 = insert(:fantasy_player, sports_league: sport)
      player4 = insert(:fantasy_player, sports_league: sport)

      team = insert(:fantasy_team)
      team2 = insert(:fantasy_team)

      queue = insert(:draft_queue, fantasy_player: player2, fantasy_team: team)
      insert(:draft_queue, fantasy_player: player4, fantasy_team: team, order: 2)
      insert(:draft_queue, fantasy_player: player, fantasy_team: team, order: 1)
      insert(:draft_queue, fantasy_player: player3, fantasy_team: team, status: :drafted)
      insert(:draft_queue, fantasy_player: player, fantasy_team: team2)

      result = DraftQueues.get_top_queue(team.id)

      assert result.id == queue.id
    end
  end

  describe "get_top_queue_by_sport/2" do
    test "returns pending draft queues for a team and sport" do
      sport = insert(:sports_league)
      sport2 = insert(:sports_league)

      player = insert(:fantasy_player, sports_league: sport)
      player2 = insert(:fantasy_player, sports_league: sport2)
      player3 = insert(:fantasy_player, sports_league: sport)
      player4 = insert(:fantasy_player, sports_league: sport)

      team = insert(:fantasy_team)
      team2 = insert(:fantasy_team)

      insert(:draft_queue, fantasy_player: player4, fantasy_team: team, order: 2)
      queue = insert(:draft_queue, fantasy_player: player, fantasy_team: team, order: 1)
      insert(:draft_queue, fantasy_player: player3, fantasy_team: team, status: :drafted)
      insert(:draft_queue, fantasy_player: player2, fantasy_team: team)
      insert(:draft_queue, fantasy_player: player, fantasy_team: team2)

      result = DraftQueues.get_top_queue_by_sport(team.id, sport.id)

      assert result.id == queue.id
    end
  end

  describe "archive_pending_queues/1" do
    test "archives all pending picks for a league" do
      league = insert(:fantasy_league)
      other_league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      other_team = insert(:fantasy_team, fantasy_league: other_league)

      queue = insert(:draft_queue, fantasy_team: team, status: :pending)
      other_queue = insert(:draft_queue, fantasy_team: other_team, status: :pending)
      drafted_queue = insert(:draft_queue, fantasy_team: team, status: :drafted)

      {1, nil} = DraftQueues.archive_pending_queues(league.id)

      assert DraftQueues.get_draft_queue!(queue.id).status == :archived
      assert DraftQueues.get_draft_queue!(other_queue.id).status == :pending
      assert DraftQueues.get_draft_queue!(drafted_queue.id).status == :drafted
    end
  end

  describe "reorder_for_league/1" do
    test "updates pending draft queues for a league" do
      league = insert(:fantasy_league)
      sport = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: sport)
      insert(:championship, sports_league: sport)
      player = insert(:fantasy_player, sports_league: sport)
      player2 = insert(:fantasy_player, sports_league: sport)

      team = insert(:fantasy_team, fantasy_league: league)
      insert(:draft_queue, fantasy_team: team, fantasy_player: player, order: 2)
      insert(:draft_queue, fantasy_team: team, fantasy_player: player2, order: 3)

      team2 = insert(:fantasy_team, fantasy_league: league)
      insert(:draft_queue, fantasy_team: team2, fantasy_player: player, order: 3)
      insert(:draft_queue, fantasy_team: team2, fantasy_player: player2, order: 5)

      insert(
        :draft_queue,
        fantasy_team: team2,
        fantasy_player: player,
        order: 1,
        status: :cancelled
      )

      other_league = insert(:fantasy_league)
      insert(:league_sport, fantasy_league: other_league, sports_league: sport)
      other_team = insert(:fantasy_team, fantasy_league: other_league)
      insert(:draft_queue, fantasy_team: other_team, fantasy_player: player, order: 2)

      DraftQueues.reorder_for_league(league.id)

      queues =
        DraftQueue
        |> Repo.all()
        |> Enum.sort_by(& &1.id)

      assert Enum.map(queues, & &1.order) == [1, 2, 1, 2, 1, 2]
    end
  end
end
