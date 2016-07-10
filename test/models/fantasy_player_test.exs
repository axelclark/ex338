defmodule Ex338.FantasyPlayerTest do
  @moduledoc false

  use Ex338.ModelCase

  alias Ex338.FantasyPlayer

  @valid_attrs %{player_name: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = FantasyPlayer.changeset(%FantasyPlayer{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = FantasyPlayer.changeset(%FantasyPlayer{}, @invalid_attrs)
    refute changeset.valid?
  end
end
