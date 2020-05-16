defmodule Ex338.FantasyTeamsTest do
  use Ex338.DataCase

  alias Ex338.FantasyTeams

  describe "fantasy_teams" do
    alias Ex338.FantasyTeams.FantasyTeam

    @valid_attrs %{autodraft_setting: "some autodraft_setting", avg_seconds_on_the_clock: 42, commish_notes: "some commish_notes", dues_paid: 120.5, max_flex_adj: 42, picks_selected: 42, team_name: "some team_name", total_draft_mins_adj: 42, total_seconds_on_the_clock: 42, waiver_position: 42, winnings_adj: 120.5, winnings_received: 120.5}
    @update_attrs %{autodraft_setting: "some updated autodraft_setting", avg_seconds_on_the_clock: 43, commish_notes: "some updated commish_notes", dues_paid: 456.7, max_flex_adj: 43, picks_selected: 43, team_name: "some updated team_name", total_draft_mins_adj: 43, total_seconds_on_the_clock: 43, waiver_position: 43, winnings_adj: 456.7, winnings_received: 456.7}
    @invalid_attrs %{autodraft_setting: nil, avg_seconds_on_the_clock: nil, commish_notes: nil, dues_paid: nil, max_flex_adj: nil, picks_selected: nil, team_name: nil, total_draft_mins_adj: nil, total_seconds_on_the_clock: nil, waiver_position: nil, winnings_adj: nil, winnings_received: nil}

    def fantasy_team_fixture(attrs \\ %{}) do
      {:ok, fantasy_team} =
        attrs
        |> Enum.into(@valid_attrs)
        |> FantasyTeams.create_fantasy_team()

      fantasy_team
    end

    test "list_fantasy_teams/0 returns all fantasy_teams" do
      fantasy_team = fantasy_team_fixture()
      assert FantasyTeams.list_fantasy_teams() == [fantasy_team]
    end

    test "get_fantasy_team!/1 returns the fantasy_team with given id" do
      fantasy_team = fantasy_team_fixture()
      assert FantasyTeams.get_fantasy_team!(fantasy_team.id) == fantasy_team
    end

    test "create_fantasy_team/1 with valid data creates a fantasy_team" do
      assert {:ok, %FantasyTeam{} = fantasy_team} = FantasyTeams.create_fantasy_team(@valid_attrs)
      assert fantasy_team.autodraft_setting == "some autodraft_setting"
      assert fantasy_team.avg_seconds_on_the_clock == 42
      assert fantasy_team.commish_notes == "some commish_notes"
      assert fantasy_team.dues_paid == 120.5
      assert fantasy_team.max_flex_adj == 42
      assert fantasy_team.picks_selected == 42
      assert fantasy_team.team_name == "some team_name"
      assert fantasy_team.total_draft_mins_adj == 42
      assert fantasy_team.total_seconds_on_the_clock == 42
      assert fantasy_team.waiver_position == 42
      assert fantasy_team.winnings_adj == 120.5
      assert fantasy_team.winnings_received == 120.5
    end

    test "create_fantasy_team/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = FantasyTeams.create_fantasy_team(@invalid_attrs)
    end

    test "update_fantasy_team/2 with valid data updates the fantasy_team" do
      fantasy_team = fantasy_team_fixture()
      assert {:ok, %FantasyTeam{} = fantasy_team} = FantasyTeams.update_fantasy_team(fantasy_team, @update_attrs)
      assert fantasy_team.autodraft_setting == "some updated autodraft_setting"
      assert fantasy_team.avg_seconds_on_the_clock == 43
      assert fantasy_team.commish_notes == "some updated commish_notes"
      assert fantasy_team.dues_paid == 456.7
      assert fantasy_team.max_flex_adj == 43
      assert fantasy_team.picks_selected == 43
      assert fantasy_team.team_name == "some updated team_name"
      assert fantasy_team.total_draft_mins_adj == 43
      assert fantasy_team.total_seconds_on_the_clock == 43
      assert fantasy_team.waiver_position == 43
      assert fantasy_team.winnings_adj == 456.7
      assert fantasy_team.winnings_received == 456.7
    end

    test "update_fantasy_team/2 with invalid data returns error changeset" do
      fantasy_team = fantasy_team_fixture()
      assert {:error, %Ecto.Changeset{}} = FantasyTeams.update_fantasy_team(fantasy_team, @invalid_attrs)
      assert fantasy_team == FantasyTeams.get_fantasy_team!(fantasy_team.id)
    end

    test "delete_fantasy_team/1 deletes the fantasy_team" do
      fantasy_team = fantasy_team_fixture()
      assert {:ok, %FantasyTeam{}} = FantasyTeams.delete_fantasy_team(fantasy_team)
      assert_raise Ecto.NoResultsError, fn -> FantasyTeams.get_fantasy_team!(fantasy_team.id) end
    end

    test "change_fantasy_team/1 returns a fantasy_team changeset" do
      fantasy_team = fantasy_team_fixture()
      assert %Ecto.Changeset{} = FantasyTeams.change_fantasy_team(fantasy_team)
    end
  end
end
