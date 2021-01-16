defmodule Ex338Web.TradeViewTest do
  use Ex338Web.ConnCase, async: true

  alias Ex338Web.TradeView
  alias Ex338.{FantasyTeams.FantasyTeam, Trades.Trade, Trades.TradeLineItem, Accounts.User}

  describe "allow_vote?/2" do
    test "returns true if team can still vote" do
      trade = %{
        status: "Pending",
        trade_votes: [
          %{fantasy_team_id: 1},
          %{fantasy_team_id: 2}
        ]
      }

      current_user = %{
        fantasy_teams: [%{id: 3, fantasy_league_id: 1}, %{id: 5, fantasy_league_id: 2}]
      }

      fantasy_league = %{id: 1}

      result = TradeView.allow_vote?(trade, current_user, fantasy_league)

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

      current_user = %{
        fantasy_teams: [%{id: 1, fantasy_league_id: 1}, %{id: 5, fantasy_league_id: 2}]
      }

      fantasy_league = %{id: 1}

      result = TradeView.allow_vote?(trade, current_user, fantasy_league)

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

      current_user = %{fantasy_teams: [%{id: 3, fantasy_league_id: 1}]}

      fantasy_league = %{id: 1}

      result = TradeView.allow_vote?(trade, current_user, fantasy_league)

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

      current_user = %{fantasy_teams: [%{id: 3, fantasy_league_id: 1}]}

      fantasy_league = %{id: 2}

      result = TradeView.allow_vote?(trade, current_user, fantasy_league)

      assert result == false
    end
  end

  describe "get_team_for_league/2" do
    test "returns a fantasy team from a fantasy league" do
      fantasy_teams = [%{id: 1, fantasy_league_id: 1}]

      fantasy_league = %{id: 1}

      result = TradeView.get_team_for_league(fantasy_teams, fantasy_league)

      assert result.id == 1
    end

    test "returns :no_team if there are no teams" do
      fantasy_teams = %{}
      fantasy_league = %{id: 1}

      result = TradeView.get_team_for_league(fantasy_teams, fantasy_league)

      assert result == :no_team
    end

    test "raises if multiple fantasy teams from a fantasy league" do
      fantasy_teams = [%{id: 1, fantasy_league_id: 1}, %{id: 2, fantasy_league_id: 1}]

      fantasy_league = %{id: 1}

      assert_raise RuntimeError, fn ->
        TradeView.get_team_for_league(fantasy_teams, fantasy_league)
      end
    end
  end

  describe "proposed_for_team?/2" do
    test "returns true if Proposed and user is admin" do
      trade = %Trade{status: "Proposed"}
      user = %User{admin: true}

      assert TradeView.proposed_for_team?(trade, user) == true
    end

    test "returns true if Proposed and team is involved" do
      team = %FantasyTeam{id: 1}

      trade = %Trade{
        status: "Proposed",
        trade_line_items: [%TradeLineItem{gaining_team: team, losing_team: team}]
      }

      user = %User{admin: false, fantasy_teams: [team]}

      assert TradeView.proposed_for_team?(trade, user) == true
    end

    test "returns true if Proposed and team is involved and own multiple teams" do
      team = %FantasyTeam{id: 1}
      other_team = %FantasyTeam{id: 2}

      trade = %Trade{
        status: "Proposed",
        trade_line_items: [%TradeLineItem{gaining_team: team, losing_team: team}]
      }

      user = %User{admin: false, fantasy_teams: [team, other_team]}

      assert TradeView.proposed_for_team?(trade, user) == true
    end

    test "returns false if Proposed and team is NOT involved" do
      team_a = %FantasyTeam{id: 1}

      trade = %Trade{
        status: "Proposed",
        trade_line_items: [%TradeLineItem{gaining_team: team_a, losing_team: team_a}]
      }

      team_b = %FantasyTeam{id: 2}
      user = %User{admin: false, fantasy_teams: [team_b]}

      assert TradeView.proposed_for_team?(trade, user) == false
    end
  end
end
