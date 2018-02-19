defmodule Ex338.DraftPickTest do
  use Ex338.DataCase, async: true

  alias Ex338.DraftPick

  @valid_attrs %{draft_position: "1.05", round: 42, fantasy_league_id: 1}
  @valid_user_attrs %{
    draft_position: "1.05",
    round: 42,
    fantasy_league_id: 1,
    fantasy_team_id: 1,
    fantasy_player_id: 1
  }
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = DraftPick.changeset(%DraftPick{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = DraftPick.changeset(%DraftPick{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "owner_changeset with valid attributes" do
    changeset = DraftPick.owner_changeset(%DraftPick{}, @valid_user_attrs)
    assert changeset.valid?
  end

  test "owner_changeset only allows update to fantasy player" do
    changeset = DraftPick.owner_changeset(%DraftPick{}, @valid_user_attrs)
    assert changeset.changes == %{fantasy_player_id: 1}
  end

  test "owner_changeset with invalid attributes" do
    changeset = DraftPick.owner_changeset(%DraftPick{}, @valid_attrs)
    refute changeset.valid?
  end
end
