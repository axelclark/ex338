defmodule Ex338.DraftQueueTest do
  use Ex338.DataCase, async: true

  alias Ex338.DraftQueue

  @valid_attrs %{
    order: 1,
    fantasy_team_id: 2,
    fantasy_player_id: 3
  }
  @invalid_attrs %{}

  describe "changeset/2" do
    test "valid with valid attributes" do
      changeset = DraftQueue.changeset(%DraftQueue{}, @valid_attrs)
      assert changeset.valid?
    end

    test "invalid with invalid attributes" do
      changeset = DraftQueue.changeset(%DraftQueue{}, @invalid_attrs)
      refute changeset.valid?
    end

    test "invalid with invalid status enum" do
      attrs = Map.put(@valid_attrs, :status, "wrong")
      changeset = DraftQueue.changeset(%DraftQueue{}, attrs)
      refute changeset.valid?
    end
  end

  describe "preload_assocs/1" do
    test "preloads assocs for DraftQueue struct" do
      player = insert(:fantasy_player)
      team = insert(:fantasy_team)
      insert(:draft_queue, fantasy_team: team, fantasy_player: player)

      result = DraftQueue
               |> DraftQueue.preload_assocs
               |> Repo.one

      assert result.fantasy_team.id == team.id
      assert result.fantasy_player.id == player.id
    end
  end
end
