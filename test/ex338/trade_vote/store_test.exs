defmodule Ex338.TradeVote.StoreTest do
  use Ex338.DataCase
  alias Ex338.TradeVote.Store

  describe "create_vote/1" do
    test "creates a new vote from params" do
      trade = insert(:trade)
      team = insert(:fantasy_team)
      user = insert(:user)
      attrs =
        %{
          "trade_id" => trade.id,
          "fantasy_team_id" => team.id,
          "user_id" => user.id,
          "approve" => true,
        }

      {:ok, result} = Store.create_vote(attrs)

      assert result.trade_id == trade.id
      assert result.fantasy_team_id == team.id
      assert result.user_id == user.id
      assert result.approve == true
    end
  end
end
