defmodule Ex338.FantasyTeamTest do
  @moduledoc false

  use Ex338.ModelCase

  alias Ex338.FantasyTeam

  @valid_attrs %{team_name: "some content", waiver_position: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = FantasyTeam.changeset(%FantasyTeam{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = FantasyTeam.changeset(%FantasyTeam{}, @invalid_attrs)
    refute changeset.valid?
  end
end
