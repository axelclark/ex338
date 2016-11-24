defmodule Ex338.WaiverAdminTest do
  use Ex338.ModelCase
  alias Ex338.{WaiverAdmin, Waiver}
  alias Ecto.Multi

  @waiver %Waiver{
    fantasy_team_id:          1,
    add_fantasy_player_id:    2,
    drop_fantasy_player_id:   3,
    process_at: Ecto.DateTime.utc,
  }

  @drop_waiver %Waiver{
    fantasy_team_id:          1,
    add_fantasy_player_id:    nil,
    drop_fantasy_player_id:   3,
    process_at: Ecto.DateTime.utc,
  }

  @add_waiver %Waiver{
    fantasy_team_id:          1,
    add_fantasy_player_id:    2,
    drop_fantasy_player_id:   nil,
    process_at: Ecto.DateTime.utc,
  }

  describe "update_waiver_status/3" do
    test "with successful status, returns a multi with valid changeset" do
      params = %{"status" => "successful"}

      multi = WaiverAdmin.update_waiver_status(Multi.new, @waiver, params)

      assert [
        {:waiver, {:update, waiver_changeset, []}}
      ] = Ecto.Multi.to_list(multi)

      assert waiver_changeset.valid?
    end

    test "with unsuccessful status, returns a multi with valid changeset" do
      params = %{"status" => "unsuccessful"}

      multi = WaiverAdmin.update_waiver_status(Multi.new, @waiver, params)

      assert [
        {:waiver, {:update, waiver_changeset, []}}
      ] = Ecto.Multi.to_list(multi)

      assert waiver_changeset.valid?
    end
  end

  describe "insert_new_position/2" do
    test "without an add, returns a multi with no changes" do
      multi = WaiverAdmin.insert_new_position(Multi.new, @drop_waiver)

      assert [] = Ecto.Multi.to_list(multi)
    end

    test "without a drop, returns a multi with valid changeset" do
      multi = WaiverAdmin.insert_new_position(Multi.new, @add_waiver)

      assert [
        {:new_roster_position, {:insert, roster_position_changeset, []}}
      ] = Ecto.Multi.to_list(multi)

      assert roster_position_changeset.valid?
    end

    test "add and drop waiver returns a multi with valid changeset" do
      multi = WaiverAdmin.insert_new_position(Multi.new, @waiver)

      assert [
        {:new_roster_position, {:insert, roster_position_changeset, []}}
      ] = Ecto.Multi.to_list(multi)

      assert roster_position_changeset.valid?
    end
  end

  describe "drop_roster_position/2" do
    test "waiver without a player to drop return a multi with no changes" do
      multi = WaiverAdmin.drop_roster_position(Multi.new, @add_waiver)

      assert [] = Ecto.Multi.to_list(multi)
    end

    test "with add and drop, returns roster position with changes to dropped" do
      multi = WaiverAdmin.drop_roster_position(Multi.new, @waiver)

      assert [
        {:delete_roster_position, {:update_all, query, [], []}}
      ] = Ecto.Multi.to_list(multi)

      assert inspect(query) =~ ~r/#Ecto.Query<from r in Ex338.RosterPosition/
    end
  end

  describe "update_league_waivers/2" do
    test "with only a drop, returns a multi with no change" do
      multi = WaiverAdmin.update_league_waivers(Multi.new, @drop_waiver)

      assert [] = Ecto.Multi.to_list(multi)
    end

    test "with add and drop, returns a valid fantasy team changeset" do
      waiver = insert(:waiver)

      multi = WaiverAdmin.update_league_waivers(Multi.new, waiver)

      assert [
        {:league_waiver_update, {:update_all, query, [], []}}
      ] = Ecto.Multi.to_list(multi)

      assert inspect(query) =~ ~r/#Ecto.Query<from f in Ex338.FantasyTeam/
    end
  end

  describe "update_team_waiver_position/2" do
    test "with only a drop, returns a multi with no change" do
      multi = WaiverAdmin.update_team_waiver_position(Multi.new, @drop_waiver)

      assert [] = Ecto.Multi.to_list(multi)
    end

    test "with add and drop, returns valid fantasy team changeset" do
      league = insert(:fantasy_league)
      team_a = insert(:fantasy_team, fantasy_league: league)
      waiver = insert(:waiver, fantasy_team: team_a)
      _other_team = insert(:fantasy_team, fantasy_league: league)

      multi = WaiverAdmin.update_team_waiver_position(Multi.new, waiver)

      assert [
        {:team_waiver_update, {:update, fantasy_team_changeset, []}}
      ] = Ecto.Multi.to_list(multi)

      assert fantasy_team_changeset.valid?
      assert fantasy_team_changeset.changes.waiver_position == 2
    end
  end
end
