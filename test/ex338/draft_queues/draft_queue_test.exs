defmodule Ex338.DraftQueues.DraftQueueTest do
  use Ex338.DataCase, async: true

  alias Ex338.DraftQueues.DraftQueue

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

      [q1, q2] =
        DraftQueue
        |> DraftQueue.by_league(league.id)
        |> Repo.all()
        |> Enum.sort_by(& &1.id)

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

  describe "by_sport/2" do
    test "returns draft queues for a sport" do
      sport = insert(:sports_league)
      sport2 = insert(:sports_league)
      player = insert(:fantasy_player, sports_league: sport)
      player2 = insert(:fantasy_player, sports_league: sport2)
      queue = insert(:draft_queue, fantasy_player: player)
      insert(:draft_queue, fantasy_player: player2)

      result =
        DraftQueue
        |> DraftQueue.by_sport(sport.id)
        |> Repo.one()

      assert result.id == queue.id
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

  describe "changeset/2" do
    test "valid with valid attributes" do
      league = insert(:fantasy_league, max_flex_spots: 5)
      team = insert(:fantasy_team, fantasy_league: league)
      player = insert(:fantasy_player)

      attrs = %{
        fantasy_team_id: team.id,
        fantasy_player_id: player.id,
        order: 1
      }

      changeset = DraftQueue.changeset(%DraftQueue{}, attrs)

      assert changeset.valid?
    end

    test "invalid with invalid attributes" do
      league = insert(:fantasy_league, max_flex_spots: 5)
      team = insert(:fantasy_team, fantasy_league: league)
      insert(:fantasy_player)

      invalid_attrs = %{
        fantasy_team_id: team.id,
        fantasy_player_id: nil,
        order: 1
      }

      changeset = DraftQueue.changeset(%DraftQueue{}, invalid_attrs)

      refute changeset.valid?
    end

    test "invalid with invalid status enum" do
      league = insert(:fantasy_league, max_flex_spots: 5)
      team = insert(:fantasy_team, fantasy_league: league)
      player = insert(:fantasy_player)

      attrs = %{
        fantasy_team_id: team.id,
        fantasy_player_id: player.id,
        order: 1,
        status: "wrong"
      }

      changeset = DraftQueue.changeset(%DraftQueue{}, attrs)

      refute changeset.valid?
    end

    test "valid when under max flex slots" do
      league = insert(:fantasy_league, max_flex_spots: 5)
      team = insert(:fantasy_team, fantasy_league: league)
      regular_positions = insert_list(4, :roster_position, fantasy_team: team)

      flex_sport = List.first(regular_positions).fantasy_player.sports_league

      [add | plyrs] = insert_list(5, :fantasy_player, sports_league: flex_sport)

      _flex_slots =
        for plyr <- plyrs do
          insert(:roster_position, fantasy_team: team, fantasy_player: plyr)
        end

      attrs = %{
        order: 1,
        fantasy_team_id: team.id,
        fantasy_player_id: add.id
      }

      changeset = DraftQueue.changeset(%DraftQueue{}, attrs)

      assert changeset.valid?
    end

    test "error if too many flex spots in use" do
      league = insert(:fantasy_league, max_flex_spots: 5)
      team = insert(:fantasy_team, fantasy_league: league)
      regular_positions = insert_list(4, :roster_position, fantasy_team: team)

      flex_sport = List.first(regular_positions).fantasy_player.sports_league

      [add | plyrs] = insert_list(7, :fantasy_player, sports_league: flex_sport)

      _flex_slots =
        for plyr <- plyrs do
          insert(:roster_position, fantasy_team: team, fantasy_player: plyr)
        end

      attrs = %{
        fantasy_team_id: team.id,
        fantasy_player_id: add.id,
        order: 1
      }

      changeset = DraftQueue.changeset(%DraftQueue{}, attrs)

      assert changeset.errors == [
               fantasy_player_id: {"No flex position available for this player", []}
             ]
    end

    test "no error if unavailable when too many flex spots in use" do
      league = insert(:fantasy_league, max_flex_spots: 5)
      team = insert(:fantasy_team, fantasy_league: league)
      regular_positions = insert_list(4, :roster_position, fantasy_team: team)

      flex_sport = List.first(regular_positions).fantasy_player.sports_league

      [add | plyrs] = insert_list(7, :fantasy_player, sports_league: flex_sport)

      _flex_slots =
        for plyr <- plyrs do
          insert(:roster_position, fantasy_team: team, fantasy_player: plyr)
        end

      attrs = %{
        fantasy_team_id: team.id,
        fantasy_player_id: add.id,
        order: 1,
        status: "unavailable"
      }

      changeset = DraftQueue.changeset(%DraftQueue{}, attrs)

      assert changeset.valid?
    end

    test "no error if cancelled when too many flex spots in use" do
      league = insert(:fantasy_league, max_flex_spots: 5)
      team = insert(:fantasy_team, fantasy_league: league)
      regular_positions = insert_list(4, :roster_position, fantasy_team: team)

      flex_sport = List.first(regular_positions).fantasy_player.sports_league

      [add | plyrs] = insert_list(7, :fantasy_player, sports_league: flex_sport)

      _flex_slots =
        for plyr <- plyrs do
          insert(:roster_position, fantasy_team: team, fantasy_player: plyr)
        end

      attrs = %{
        fantasy_team_id: team.id,
        fantasy_player_id: add.id,
        order: 1,
        status: "cancelled"
      }

      changeset = DraftQueue.changeset(%DraftQueue{}, attrs)

      assert changeset.valid?
    end

    test "no error if for too many flex spots when in season draft is on" do
      sport = insert(:sports_league)
      league = insert(:fantasy_league, max_flex_spots: 5, sport_draft: sport)
      team = insert(:fantasy_team, fantasy_league: league)
      regular_positions = insert_list(4, :roster_position, fantasy_team: team)

      flex_sport = List.first(regular_positions).fantasy_player.sports_league

      [add | plyrs] = insert_list(7, :fantasy_player, sports_league: flex_sport)

      _flex_slots =
        for plyr <- plyrs do
          insert(:roster_position, fantasy_team: team, fantasy_player: plyr)
        end

      attrs = %{
        fantasy_team_id: team.id,
        fantasy_player_id: add.id,
        order: 1
      }

      changeset = DraftQueue.changeset(%DraftQueue{}, attrs)

      assert changeset.valid?
    end

    # test "valid if team needs player to fill sport position" do
    #   league = insert(:fantasy_league)
    #   team_a = insert(:fantasy_team, fantasy_league: league)
    #   team_b = insert(:fantasy_team, fantasy_league: league)

    #   sport = insert(:sports_league)
    #   insert(:league_sport, sports_league: sport, fantasy_league: league)
    #   player_a = insert(:fantasy_player, sports_league: sport)
    #   player_b = insert(:fantasy_player, sports_league: sport)

    #   insert(:roster_position, fantasy_team: team_a, fantasy_player: player_a)

    #   attrs = %{
    #     fantasy_team_id: team_b.id,
    #     fantasy_player_id: player_b.id,
    #     order: 1
    #   }

    #   changeset = DraftQueue.changeset(%DraftQueue{}, attrs)

    #   assert changeset.valid?
    # end

    # test "error if available players equal to teams needing to fill league rosters" do
    #   league = insert(:fantasy_league)
    #   team_a = insert(:fantasy_team, fantasy_league: league)
    #   _team_b = insert(:fantasy_team, fantasy_league: league)

    #   sport = insert(:sports_league)
    #   insert(:league_sport, sports_league: sport, fantasy_league: league)
    #   player_a = insert(:fantasy_player, sports_league: sport)
    #   player_b = insert(:fantasy_player, sports_league: sport)

    #   insert(:roster_position, fantasy_team: team_a, fantasy_player: player_a)

    #   attrs = %{
    #     fantasy_team_id: team_a.id,
    #     fantasy_player_id: player_b.id,
    #     order: 1
    #   }

    #   changeset = DraftQueue.changeset(%DraftQueue{}, attrs)

    #   assert changeset.errors == [
    #            fantasy_player_id:
    #              {"Number of available players equal to number of teams with need", []}
    #          ]
    # end

    # test "error if available players less than teams needing to fill league rosters" do
    #   league = insert(:fantasy_league)
    #   team_a = insert(:fantasy_team, fantasy_league: league)
    #   _team_b = insert(:fantasy_team, fantasy_league: league)
    #   _team_c = insert(:fantasy_team, fantasy_league: league)

    #   sport = insert(:sports_league)
    #   insert(:league_sport, sports_league: sport, fantasy_league: league)
    #   player_a = insert(:fantasy_player, sports_league: sport)
    #   player_b = insert(:fantasy_player, sports_league: sport)

    #   insert(:roster_position, fantasy_team: team_a, fantasy_player: player_a)

    #   attrs = %{
    #     fantasy_team_id: team_a.id,
    #     fantasy_player_id: player_b.id,
    #     order: 1
    #   }

    #   changeset = DraftQueue.changeset(%DraftQueue{}, attrs)

    #   assert changeset.errors == [
    #            fantasy_player_id:
    #              {"Number of available players equal to number of teams with need", []}
    #          ]
    # end
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

  describe "ordered/1" do
    test "returns only pending draft queues" do
      insert(:draft_queue, order: 2)
      insert(:draft_queue, order: 1)

      result =
        DraftQueue
        |> DraftQueue.ordered()
        |> Repo.all()
        |> Enum.map(& &1.order)

      assert result == [1, 2]
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

      {2, nil} =
        DraftQueue
        |> DraftQueue.update_to_drafted()
        |> Repo.update_all([])

      results = Repo.all(DraftQueue)

      assert Enum.map(results, & &1.status) == [:drafted, :drafted]
    end
  end

  describe "update_to_unavailable/1" do
    test "query to update status to unavailable" do
      insert(:draft_queue, status: :pending)
      insert(:draft_queue, status: :pending)

      {2, nil} =
        DraftQueue
        |> DraftQueue.update_to_unavailable()
        |> Repo.update_all([], returning: true)

      results = Repo.all(DraftQueue)

      assert Enum.map(results, & &1.status) == [:unavailable, :unavailable]
    end
  end
end
