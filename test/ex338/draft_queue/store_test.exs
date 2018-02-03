defmodule Ex338.DraftQueue.StoreTest do
  use Ex338.DataCase, async: true

  alias Ex338.{DraftQueue.Store}

  describe "create_draft_queue" do
    test "creates a draft queue with valid attributes" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      sport = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: sport)
      insert(:championship, sports_league: sport)
      player = insert(:fantasy_player, sports_league: sport)
      attrs = %{"fantasy_team_id" => team.id, "fantasy_player_id" => player.id}

      {:ok, result} = Store.create_draft_queue(attrs)

      assert result.fantasy_team_id == team.id
      assert result.fantasy_player_id == player.id
      assert result.status == "pending"
      assert result.order == 1
    end

    test "returns an error with invalid attributes" do
      assert {:error, %Ecto.Changeset{}} = Store.create_draft_queue(%{})
    end
  end
end
