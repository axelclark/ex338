defmodule Ex338.DraftQueues.AdminTest do
  use Ex338.DataCase, async: true

  alias Ex338.{DraftQueues.Admin, DraftQueues.DraftQueue}

  describe "update_drafted_from_pick/1" do
    test "updates pending draft queues to drafted from a draft pick" do
      league = insert(:fantasy_league)
      sport = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: sport)
      insert(:championship, sports_league: sport)
      player = insert(:fantasy_player, sports_league: sport)

      team = insert(:fantasy_team, fantasy_league: league)
      insert(:draft_queue, fantasy_team: team, fantasy_player: player)

      other_league = insert(:fantasy_league)
      insert(:league_sport, fantasy_league: other_league, sports_league: sport)
      other_team = insert(:fantasy_team, fantasy_league: other_league)
      insert(:draft_queue, fantasy_team: other_team, fantasy_player: player)

      team_with_pick = insert(:fantasy_team, fantasy_league: league)

      _cancelled_queue =
        insert(
          :draft_queue,
          fantasy_team: team_with_pick,
          fantasy_player: player,
          status: :cancelled
        )

      _drafted_queue =
        insert(
          :draft_queue,
          fantasy_team: team_with_pick,
          fantasy_player: player
        )

      draft_pick = insert(:draft_pick, fantasy_team: team_with_pick, fantasy_player: player)

      {num_updated, _updated_queues} =
        draft_pick
        |> Admin.update_drafted_from_pick()
        |> Repo.update_all([], returning: true)

      [q1, q2, q3, q4] =
        DraftQueue
        |> Repo.all()
        |> Enum.sort_by(& &1.id)

      assert num_updated == 1
      assert q1.status == :pending
      assert q2.status == :pending
      assert q3.status == :cancelled
      assert q4.status == :drafted
    end

    test "updates pending draft queues to drafted from an inseason draft pick" do
      league = insert(:fantasy_league)
      sport = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: sport)
      championship = insert(:championship, sports_league: sport)
      player = insert(:fantasy_player, sports_league: sport)

      team = insert(:fantasy_team, fantasy_league: league)
      insert(:draft_queue, fantasy_team: team, fantasy_player: player)
      team2 = insert(:fantasy_team, fantasy_league: league)
      insert(:draft_queue, fantasy_team: team2, fantasy_player: player)

      insert(
        :draft_queue,
        fantasy_team: team2,
        fantasy_player: player,
        status: :cancelled
      )

      other_league = insert(:fantasy_league)
      insert(:league_sport, fantasy_league: other_league, sports_league: sport)
      other_team = insert(:fantasy_team, fantasy_league: other_league)
      insert(:draft_queue, fantasy_team: other_team, fantasy_player: player)

      team_with_pick = insert(:fantasy_team, fantasy_league: league)
      pick_player = insert(:fantasy_player, sports_league: sport)

      pick_asset =
        insert(
          :roster_position,
          fantasy_team: team_with_pick,
          fantasy_player: pick_player
        )

      insert(:draft_queue, fantasy_team: team_with_pick, fantasy_player: player)

      in_season_draft_pick =
        insert(
          :in_season_draft_pick,
          position: 1,
          draft_pick_asset: pick_asset,
          championship: championship,
          drafted_player: player
        )

      {num_updated, _updated_queues} =
        in_season_draft_pick
        |> Admin.update_drafted_from_pick()
        |> Repo.update_all([], returning: true)

      [q1, q2, q3, q4, q5] =
        DraftQueue
        |> Repo.all()
        |> Enum.sort_by(& &1.id)

      assert num_updated == 1
      assert q1.status == :pending
      assert q2.status == :pending
      assert q3.status == :cancelled
      assert q4.status == :pending
      assert q5.status == :drafted
    end
  end

  describe "update_unavailable_from_pick/1" do
    test "updates pending draft queues from a draft pick" do
      league = insert(:fantasy_league)
      sport = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: sport)
      insert(:championship, sports_league: sport)
      player = insert(:fantasy_player, sports_league: sport)

      team = insert(:fantasy_team, fantasy_league: league)
      insert(:draft_queue, fantasy_team: team, fantasy_player: player)
      team2 = insert(:fantasy_team, fantasy_league: league)
      insert(:draft_queue, fantasy_team: team2, fantasy_player: player)

      insert(
        :draft_queue,
        fantasy_team: team2,
        fantasy_player: player,
        status: :cancelled
      )

      other_league = insert(:fantasy_league)
      insert(:league_sport, fantasy_league: other_league, sports_league: sport)
      other_team = insert(:fantasy_team, fantasy_league: other_league)
      insert(:draft_queue, fantasy_team: other_team, fantasy_player: player)

      team_with_pick = insert(:fantasy_team, fantasy_league: league)
      insert(:draft_queue, fantasy_team: team_with_pick, fantasy_player: player)
      draft_pick = insert(:draft_pick, fantasy_team: team_with_pick, fantasy_player: player)

      {num_updated, _updated_queues} =
        draft_pick
        |> Admin.update_unavailable_from_pick()
        |> Repo.update_all([], returning: true)

      [q1, q2, q3, q4, q5] =
        DraftQueue
        |> Repo.all()
        |> Enum.sort_by(& &1.id)

      assert num_updated == 2
      assert q1.status == :unavailable
      assert q2.status == :unavailable
      assert q3.status == :cancelled
      assert q4.status == :pending
      assert q5.status == :pending
    end

    test "updates pending draft queues from an inseason draft pick" do
      league = insert(:fantasy_league)
      sport = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: sport)
      championship = insert(:championship, sports_league: sport)
      player = insert(:fantasy_player, sports_league: sport)

      team = insert(:fantasy_team, fantasy_league: league)
      insert(:draft_queue, fantasy_team: team, fantasy_player: player)
      team2 = insert(:fantasy_team, fantasy_league: league)
      insert(:draft_queue, fantasy_team: team2, fantasy_player: player)

      insert(
        :draft_queue,
        fantasy_team: team2,
        fantasy_player: player,
        status: :cancelled
      )

      other_league = insert(:fantasy_league)
      insert(:league_sport, fantasy_league: other_league, sports_league: sport)
      other_team = insert(:fantasy_team, fantasy_league: other_league)
      insert(:draft_queue, fantasy_team: other_team, fantasy_player: player)

      team_with_pick = insert(:fantasy_team, fantasy_league: league)
      pick_player = insert(:fantasy_player, sports_league: sport)

      pick_asset =
        insert(
          :roster_position,
          fantasy_team: team_with_pick,
          fantasy_player: pick_player
        )

      insert(:draft_queue, fantasy_team: team_with_pick, fantasy_player: player)

      in_season_draft_pick =
        insert(
          :in_season_draft_pick,
          position: 1,
          draft_pick_asset: pick_asset,
          championship: championship,
          drafted_player: player
        )

      {num_updated, _updated_queues} =
        in_season_draft_pick
        |> Admin.update_unavailable_from_pick()
        |> Repo.update_all([], returning: true)

      [q1, q2, q3, q4, q5] =
        DraftQueue
        |> Repo.all()
        |> Enum.sort_by(& &1.id)

      assert num_updated == 2
      assert q1.status == :unavailable
      assert q2.status == :unavailable
      assert q3.status == :cancelled
      assert q4.status == :pending
      assert q5.status == :pending
    end
  end

  describe "reorder_for_league/1" do
    test "updates pending draft queues for a league" do
      league_queues = [
        %Ex338.DraftQueues.DraftQueue{
          fantasy_player_id: 10,
          fantasy_team_id: 1,
          id: 1,
          order: 3
        },
        %Ex338.DraftQueues.DraftQueue{
          fantasy_player_id: 11,
          fantasy_team_id: 1,
          id: 2,
          order: 5
        },
        %Ex338.DraftQueues.DraftQueue{
          fantasy_player_id: 11,
          fantasy_team_id: 2,
          id: 3,
          order: 5
        }
      ]

      result = Admin.reorder_for_league(league_queues)

      assert [
               queue_id_1: {:update_all, _, [], []},
               queue_id_2: {:update_all, _, [], []},
               queue_id_3: {:update_all, _, [], []}
             ] = Ecto.Multi.to_list(result)
    end
  end
end
