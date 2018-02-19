defmodule Ex338Web.TradeViewTest do
  use Ex338Web.ConnCase, async: true

  alias Ex338Web.TradeView

  describe "allow_vote?/2" do
    test "returns true if team can still vote" do
      trade = %{
        status: "Pending",
        trade_votes: [
          %{fantasy_team_id: 1},
          %{fantasy_team_id: 2}
        ]
      }

      current_user = %{fantasy_teams: [%{id: 3}]}

      result = TradeView.allow_vote?(trade, current_user)

      assert result == true
    end

    test "returns false if team has voted" do
      trade = %{
        status: "Pending",
        trade_votes: [
          %{fantasy_team_id: 1},
          %{fantasy_team_id: 2}
        ]
      }

      current_user = %{fantasy_teams: [%{id: 2}]}

      result = TradeView.allow_vote?(trade, current_user)

      assert result == false
    end

    test "returns false if trade is no longer pending" do
      trade = %{
        status: "Approved",
        trade_votes: [
          %{fantasy_team_id: 1},
          %{fantasy_team_id: 2}
        ]
      }

      current_user = %{fantasy_teams: [%{id: 3}]}

      result = TradeView.allow_vote?(trade, current_user)

      assert result == false
    end

    test "returns false if user doesn't own teams in the league" do
      trade = %{
        status: "Pending",
        trade_votes: [
          %{fantasy_team_id: 1},
          %{fantasy_team_id: 2}
        ]
      }

      current_user = %{fantasy_teams: []}

      result = TradeView.allow_vote?(trade, current_user)

      assert result == false
    end
  end

  describe "get_team/1" do
    test "returns fantasy team from current user" do
      current_user = %{
        fantasy_teams: [
          %{id: 1}
        ]
      }

      result = TradeView.get_team(current_user)

      assert result.id == 1
    end

    test "returns :no_team if there are no teams" do
      current_user = %{fantasy_teams: []}

      result = TradeView.get_team(current_user)

      assert result == :no_team
    end
  end
end
