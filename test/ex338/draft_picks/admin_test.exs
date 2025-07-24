defmodule Ex338.DraftPicks.AdminTest do
  use Ex338.DataCase, async: true

  alias Ex338.DraftPicks.Admin

  describe "draft_player/1" do
    test "dry run draft_player ecto multi" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      draft_pick = insert(:draft_pick, fantasy_team: team, fantasy_league: league)
      player = insert(:fantasy_player)
      params = %{"fantasy_player_id" => player.id}

      multi = Admin.draft_player(draft_pick, params)

      assert [
               {:draft_pick, {:update, _draft_pick_changeset, []}},
               {:roster_position, {:insert, _roster_position_changeset, []}},
               {:unavailable_draft_queues, {:update_all, _, [], returning: true}},
               {:drafted_draft_queues, {:update_all, _, [], returning: true}}
             ] = Ecto.Multi.to_list(multi)
    end

    test "updates next keeper pick drafted_at when next pick is a keeper with player" do
      league = insert(:fantasy_league)
      team1 = insert(:fantasy_team, fantasy_league: league)
      team2 = insert(:fantasy_team, fantasy_league: league)

      current_pick =
        insert(:draft_pick,
          fantasy_team: team1,
          fantasy_league: league,
          draft_position: 1.0
        )

      keeper_player = insert(:fantasy_player)

      _next_pick =
        insert(:draft_pick,
          fantasy_team: team2,
          fantasy_league: league,
          draft_position: 2.0,
          fantasy_player: keeper_player,
          is_keeper: true,
          drafted_at: nil
        )

      player = insert(:fantasy_player)
      params = %{"fantasy_player_id" => player.id}

      multi = Admin.draft_player(current_pick, params)

      assert [
               {:draft_pick, {:update, _draft_pick_changeset, []}},
               {:roster_position, {:insert, _roster_position_changeset, []}},
               {:unavailable_draft_queues, {:update_all, _, [], returning: true}},
               {:drafted_draft_queues, {:update_all, _, [], returning: true}},
               {:next_keeper_drafted_at, {:update, _next_pick_changeset, []}}
             ] = Ecto.Multi.to_list(multi)
    end

    test "does not update next pick when it is not a keeper" do
      league = insert(:fantasy_league)
      team1 = insert(:fantasy_team, fantasy_league: league)
      team2 = insert(:fantasy_team, fantasy_league: league)

      current_pick =
        insert(:draft_pick,
          fantasy_team: team1,
          fantasy_league: league,
          draft_position: 1.0
        )

      regular_player = insert(:fantasy_player)

      _next_pick =
        insert(:draft_pick,
          fantasy_team: team2,
          fantasy_league: league,
          draft_position: 2.0,
          fantasy_player: regular_player,
          is_keeper: false
        )

      player = insert(:fantasy_player)
      params = %{"fantasy_player_id" => player.id}

      multi = Admin.draft_player(current_pick, params)

      assert [
               {:draft_pick, {:update, _draft_pick_changeset, []}},
               {:roster_position, {:insert, _roster_position_changeset, []}},
               {:unavailable_draft_queues, {:update_all, _, [], returning: true}},
               {:drafted_draft_queues, {:update_all, _, [], returning: true}}
             ] = Ecto.Multi.to_list(multi)
    end

    test "does not update next pick when it has no player assigned" do
      league = insert(:fantasy_league)
      team1 = insert(:fantasy_team, fantasy_league: league)
      team2 = insert(:fantasy_team, fantasy_league: league)

      current_pick =
        insert(:draft_pick,
          fantasy_team: team1,
          fantasy_league: league,
          draft_position: 1.0
        )

      _next_pick =
        insert(:draft_pick,
          fantasy_team: team2,
          fantasy_league: league,
          draft_position: 2.0,
          fantasy_player: nil,
          is_keeper: true
        )

      player = insert(:fantasy_player)
      params = %{"fantasy_player_id" => player.id}

      multi = Admin.draft_player(current_pick, params)

      assert [
               {:draft_pick, {:update, _draft_pick_changeset, []}},
               {:roster_position, {:insert, _roster_position_changeset, []}},
               {:unavailable_draft_queues, {:update_all, _, [], returning: true}},
               {:drafted_draft_queues, {:update_all, _, [], returning: true}}
             ] = Ecto.Multi.to_list(multi)
    end
  end
end
