defmodule Ex338.DraftQueueTest do
  use Ex338.DataCase, async: true

  alias Ex338.DraftQueue

  describe "by_league/2" do
    test "returns draft queues for a fantasy league" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      insert(:draft_queue, fantasy_team: team)
      team2 = insert(:fantasy_team, fantasy_league: league)
      insert(:draft_queue, fantasy_team: team2)

      other_league = insert(:fantasy_league)
      other_team = insert(:fantasy_team, fantasy_league: other_league)
      insert(:draft_queue, fantasy_team: other_team)

      [q2, q1] =
        DraftQueue
        |> DraftQueue.by_league(league.id)
        |> Repo.all()

      assert q1.fantasy_team_id == team.id
      assert q2.fantasy_team_id == team2.id
    end
  end

  describe "by_player/2" do
    test "returns draft queues for a fantasy player" do
      player = insert(:fantasy_player)
      player2 = insert(:fantasy_player)
      insert(:draft_queue, fantasy_player: player)
      insert(:draft_queue, fantasy_player: player)
      insert(:draft_queue, fantasy_player: player2)

      results =
        DraftQueue
        |> DraftQueue.by_player(player.id)
        |> Repo.all()

      assert Enum.count(results) == 2
    end
  end

  describe "by_team/2" do
    test "returns draft queues for a fantasy team" do
      team = insert(:fantasy_team)
      team2 = insert(:fantasy_team)
      queue = insert(:draft_queue, fantasy_team: team)
      insert(:draft_queue, fantasy_team: team2)

      result =
        DraftQueue
        |> DraftQueue.by_team(team.id)
        |> Repo.one()

      assert result.id == queue.id
    end
  end

  @valid_attrs %{
    order: 1,
    fantasy_team_id: 2,
    fantasy_player_id: 3
  }
  @invalid_attrs %{}

  describe "changeset/2" do
    test "valid with valid attributes" do
      changeset = DraftQueue.changeset(%DraftQueue{}, @valid_attrs)
      assert changeset.valid?
    end

    test "invalid with invalid attributes" do
      changeset = DraftQueue.changeset(%DraftQueue{}, @invalid_attrs)
      refute changeset.valid?
    end

    test "invalid with invalid status enum" do
      attrs = Map.put(@valid_attrs, :status, "wrong")
      changeset = DraftQueue.changeset(%DraftQueue{}, attrs)
      refute changeset.valid?
    end
  end

  describe "except_team/2" do
    test "returns draft queues excluding those for a fantasy team" do
      team = insert(:fantasy_team)
      team2 = insert(:fantasy_team)
      _queue = insert(:draft_queue, fantasy_team: team)
      other_queue = insert(:draft_queue, fantasy_team: team2)

      result =
        DraftQueue
        |> DraftQueue.except_team(team.id)
        |> Repo.one()

      assert result.id == other_queue.id
    end
  end

  describe "only_pending/2" do
    test "returns only pending draft queues" do
      queue = insert(:draft_queue, status: :pending)
      insert(:draft_queue, status: :cancelled)

      result =
        DraftQueue
        |> DraftQueue.only_pending()
        |> Repo.one()

      assert result.id == queue.id
    end
  end

  describe "preload_assocs/1" do
    test "preloads assocs for DraftQueue struct" do
      player = insert(:fantasy_player)
      team = insert(:fantasy_team)
      insert(:draft_queue, fantasy_team: team, fantasy_player: player)

      result =
        DraftQueue
        |> DraftQueue.preload_assocs()
        |> Repo.one()

      assert result.fantasy_team.id == team.id
      assert result.fantasy_player.id == player.id
    end
  end

  describe "update_to_drafted/1" do
    test "query to update status to drafted" do
      insert(:draft_queue, status: :pending)
      insert(:draft_queue, status: :pending)

      {2, results} =
        DraftQueue
        |> DraftQueue.update_to_drafted()
        |> Repo.update_all([], returning: true)

      assert Enum.map(results, & &1.status) == [:drafted, :drafted]
    end
  end

  describe "update_to_unavailable/1" do
    test "query to update status to unavailable" do
      insert(:draft_queue, status: :pending)
      insert(:draft_queue, status: :pending)

      {2, results} =
        DraftQueue
        |> DraftQueue.update_to_unavailable()
        |> Repo.update_all([], returning: true)

      assert Enum.map(results, & &1.status) == [:unavailable, :unavailable]
    end
  end
end
