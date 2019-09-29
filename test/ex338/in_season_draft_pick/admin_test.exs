defmodule Ex338.InSeasonDraftPick.AdminTest do
  use Ex338.DataCase

  alias Ex338.{InSeasonDraftPick.Admin, RosterPosition, FantasyPlayer}
  alias Ecto.Multi

  describe "update/2" do
    test "with valid player, returns a multi with valid changeset" do
      in_season_draft_pick = insert(:in_season_draft_pick)
      params = %{"drafted_player_id" => 1}

      multi = Admin.update(in_season_draft_pick, params)

      assert [
               {:update_pick, {:update, changeset, []}},
               {:update_position, {:update, old_pos_changeset, []}},
               {:new_position, {:insert, new_pos_changeset, []}},
               {:unavailable_draft_queues, {:update_all, _, [], returning: true}},
               {:drafted_draft_queues, {:update_all, _, [], returning: true}}
             ] = Multi.to_list(multi)

      assert changeset.valid?
      assert old_pos_changeset.valid?
      assert new_pos_changeset.valid?
    end

    test "with blank player, returns a multi with an invalid changeset" do
      in_season_draft_pick = insert(:in_season_draft_pick)
      params = %{"drafted_player_id" => ""}

      multi = Admin.update(in_season_draft_pick, params)

      assert [
               {:update_pick, {:update, changeset, []}},
               {:update_position, {:update, old_pos_changeset, []}},
               {:new_position, {:insert, _new_pos_changeset, []}},
               {:unavailable_draft_queues, {:update_all, _, [], returning: true}},
               {:drafted_draft_queues, {:update_all, _, [], returning: true}}
             ] = Multi.to_list(multi)

      refute changeset.valid?
      assert old_pos_changeset.valid?
    end
  end

  describe "generate_picks/3" do
    test "generates draft picks from KD roster positions" do
      champ_id = 1

      positions = [
        %RosterPosition{
          id: 1,
          fantasy_team: %{fantasy_league_id: 1},
          fantasy_player_id: 2,
          fantasy_player: %FantasyPlayer{player_name: "KD Pick #1"}
        },
        %RosterPosition{
          id: 2,
          fantasy_team: %{fantasy_league_id: 1},
          fantasy_player_id: 3,
          fantasy_player: %FantasyPlayer{player_name: "KD Pick #2"}
        }
      ]

      multi = Admin.generate_picks(positions, champ_id)

      assert [
               {:new_pick_1, {:insert, new_pos1_changeset, []}},
               {:new_pick_2, {:insert, new_pos2_changeset, []}}
             ] = Multi.to_list(multi)

      assert new_pos1_changeset.valid?
      assert new_pos2_changeset.valid?
    end

    test "generates draft picks from LLWS roster positions" do
      champ_id = 1

      positions = [
        %RosterPosition{
          id: 1,
          fantasy_team: %{fantasy_league_id: 1},
          fantasy_player_id: 2,
          fantasy_player: %FantasyPlayer{player_name: "LLWS Pick #1"}
        },
        %RosterPosition{
          id: 2,
          fantasy_team: %{fantasy_league_id: 1},
          fantasy_player_id: 3,
          fantasy_player: %FantasyPlayer{player_name: "LLWS Pick #2"}
        }
      ]

      multi = Admin.generate_picks(positions, champ_id)

      assert [
               {:new_pick_1, {:insert, new_pos1_changeset, []}},
               {:new_pick_2, {:insert, new_pos2_changeset, []}}
             ] = Multi.to_list(multi)

      assert new_pos1_changeset.valid?
      assert new_pos2_changeset.valid?
    end

    test "handles incorrect name" do
      champ_id = 1

      positions = [
        %RosterPosition{
          id: 1,
          fantasy_team: %{fantasy_league_id: 1},
          fantasy_player_id: 2,
          fantasy_player: %FantasyPlayer{player_name: "Wrong Name"}
        },
        %RosterPosition{
          id: 2,
          fantasy_team: %{fantasy_league_id: 1},
          fantasy_player_id: 3,
          fantasy_player: %FantasyPlayer{player_name: "Also Wrong"}
        },
        %RosterPosition{
          id: 3,
          fantasy_team: %{fantasy_league_id: 1},
          fantasy_player_id: 5,
          fantasy_player: %FantasyPlayer{player_name: "KD Pick #3"}
        }
      ]

      multi = Admin.generate_picks(positions, champ_id)

      assert [
               {_, {:insert, new_pos1_changeset, []}},
               {_, {:insert, new_pos2_changeset, []}},
               {:new_pick_3, {:insert, new_pos3_changeset, []}}
             ] = Multi.to_list(multi)

      refute new_pos1_changeset.valid?
      refute new_pos2_changeset.valid?
      assert new_pos3_changeset.valid?
    end
  end
end
