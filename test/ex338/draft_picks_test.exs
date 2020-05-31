defmodule Ex338.DraftPicksTest do
  use Ex338.DataCase

  alias Ex338.DraftPicks
  alias Ex338.DraftPicks.FuturePick

  describe "future_picks" do
    @invalid_attrs %{round: nil}

    test "change_future_pick/1 returns a future_pick changeset" do
      future_pick = insert(:future_pick)
      assert %Ecto.Changeset{} = DraftPicks.change_future_pick(future_pick)
    end

    test "create_future_pick/1 with valid data creates a future_pick" do
      team = insert(:fantasy_team)
      attrs = %{round: 42, original_team_id: team.id, current_team_id: team.id}
      assert {:ok, %FuturePick{} = result} = DraftPicks.create_future_pick(attrs)
      assert result.round == 42
    end

    test "create_future_pick/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = DraftPicks.create_future_pick(@invalid_attrs)
    end

    test "create_future_picks/2 create future picks for teams" do
      teams = insert_list(3, :fantasy_team)
      picks = 2

      results = DraftPicks.create_future_picks(teams, picks)

      assert Enum.map(results, & &1.round) == [1, 1, 1, 2, 2, 2]
    end

    test "get_future_pick!/1 returns the future_pick with given id" do
      future_pick = insert(:future_pick)
      assert DraftPicks.get_future_pick!(future_pick.id).id == future_pick.id
    end

    test "get_future_pick_by/1 returns the future_pick with given clause" do
      future_pick = insert(:future_pick, round: 1)
      _other_future_pick = insert(:future_pick, round: 2)
      assert DraftPicks.get_future_pick_by(%{round: 1}).id == future_pick.id
    end

    test "get_future_pick_by/1 returns nil if doesn't exist" do
      _future_pick = insert(:future_pick, round: 1)
      assert DraftPicks.get_future_pick_by(%{round: 2}) == nil
    end

    test "update_future_pick/2 with valid data updates the future_pick" do
      future_pick = insert(:future_pick)
      team = insert(:fantasy_team)
      attrs = %{current_team_id: team.id}

      assert {:ok, %FuturePick{} = result} = DraftPicks.update_future_pick(future_pick, attrs)

      assert result.current_team_id == team.id
    end

    test "update_future_pick/2 with invalid data returns error changeset" do
      future_pick = insert(:future_pick, round: 42)

      assert {:error, %Ecto.Changeset{}} =
               DraftPicks.update_future_pick(future_pick, @invalid_attrs)

      assert DraftPicks.get_future_pick!(future_pick.id).round == 42
    end
  end
end
