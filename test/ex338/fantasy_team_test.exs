defmodule Ex338.FantasyTeamTest do
  @moduledoc false

  use Ex338.DataCase, async: true

  alias Ex338.FantasyTeam

  @valid_attrs %{team_name: "some content", waiver_position: 42}
  @invalid_attrs %{team_name: nil}

  describe "changeset/1" do
    test "with valid attributes" do
      changeset = FantasyTeam.changeset(%FantasyTeam{}, @valid_attrs)
      assert changeset.valid?
    end

    test "with invalid attributes" do
      changeset = FantasyTeam.changeset(%FantasyTeam{}, @invalid_attrs)
      refute changeset.valid?
    end

    test "invalid with long team_name" do
      changeset = FantasyTeam.changeset(%FantasyTeam{}, %{team_name: "17lettersxxxxxxxx"})
      refute changeset.valid?
    end
  end

  describe "owner_changeset/1" do
    test "with valid attributes" do
      changeset = FantasyTeam.owner_changeset(%FantasyTeam{}, @valid_attrs)
      assert changeset.valid?
    end

    test "doesn't allow waiver update" do
      changeset = FantasyTeam.owner_changeset(%FantasyTeam{}, @valid_attrs)
      assert changeset.changes == %{team_name: "some content"}
    end

    test "with invalid attributes" do
      changeset = FantasyTeam.owner_changeset(%FantasyTeam{}, @invalid_attrs)
      refute changeset.valid?
    end

    test "invalid with long team_name" do
      changeset = FantasyTeam.owner_changeset(%FantasyTeam{}, %{team_name: "17lettersxxxxxxxx"})
      refute changeset.valid?
    end
  end

  describe "sort_alphabetical/1" do
    test "sorts teams alphabetically" do
      teams = [
        %FantasyTeam{team_name: "B", id: 2},
        %FantasyTeam{team_name: "A", id: 3},
        %FantasyTeam{team_name: "C", id: 1}
      ]

      result = FantasyTeam.sort_alphabetical(teams)

      assert Enum.map(result, & &1.team_name) == ["A", "B", "C"]
    end
  end

  describe "sort_queues_by_order/1" do
    test "returns team form struct with queues sorted by order" do
      team_struct = %FantasyTeam{draft_queues: [%{order: 2}, %{order: 1}, %{order: 3}]}

      result = FantasyTeam.sort_queues_by_order(team_struct)

      assert Enum.map(result.draft_queues, & &1.order) == [1, 2, 3]
    end
  end
end
