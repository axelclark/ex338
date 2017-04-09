defmodule Ex338.InSeasonDraftPickTest do
  use Ex338.ModelCase

  alias Ex338.InSeasonDraftPick

  @valid_attrs %{position: 42, draft_pick_asset_id: 1, championship_id: 2}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = InSeasonDraftPick.changeset(%InSeasonDraftPick{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = InSeasonDraftPick.changeset(%InSeasonDraftPick{}, @invalid_attrs)
    refute changeset.valid?
  end
end
