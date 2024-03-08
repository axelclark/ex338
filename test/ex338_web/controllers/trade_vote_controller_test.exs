defmodule Ex338Web.TradeVoteControllerTest do
  use Ex338Web.ConnCase

  import Swoosh.TestAssertions

  alias Ex338.Repo
  alias Ex338.Trades.Trade
  alias Ex338.Trades.TradeVote

  setup :register_and_log_in_user

  describe "create/2" do
    test "create a trade vote and redirect", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      team_b = insert(:fantasy_team, fantasy_league: league)
      team_c = insert(:fantasy_team, fantasy_league: league)
      user = conn.assigns.current_user
      other_user = insert(:user)
      insert(:owner, fantasy_team: team, user: user)
      insert(:owner, fantasy_team: team, user: other_user)
      sports_league = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: sports_league)
      player_a = insert(:fantasy_player, sports_league: sports_league)
      player_b = insert(:fantasy_player, sports_league: sports_league)
      insert(:roster_position, fantasy_player: player_a, fantasy_team: team_b)
      insert(:roster_position, fantasy_player: player_b, fantasy_team: team_c)
      trade = insert(:trade, submitted_by_team: team_b, submitted_by_user: other_user)

      insert(
        :trade_line_item,
        gaining_team: team_c,
        fantasy_player: player_a,
        losing_team: team_b
      )

      insert(
        :trade_line_item,
        gaining_team: team_b,
        fantasy_player: player_b,
        losing_team: team_c
      )

      attrs = %{trade_id: trade.id, approve: true}

      conn =
        post(
          conn,
          ~p"/fantasy_teams/#{team.id}/trade_votes?#{%{trade_vote: attrs}}"
        )

      result = Repo.get_by!(TradeVote, %{trade_id: trade.id, fantasy_team_id: team.id})

      assert result.fantasy_team_id == team.id
      assert result.user_id == user.id
      assert result.approve == true
      assert redirected_to(conn) == ~p"/fantasy_leagues/#{league.id}/trades"
      assert Flash.get(conn.assigns.flash, :info) == "Vote successfully submitted."
    end

    test "changes Trade to Pending if all involved teams vote yes", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      team_b = insert(:fantasy_team, fantasy_league: league)
      user = conn.assigns.current_user
      other_user = insert(:user)
      insert(:owner, fantasy_team: team, user: user)
      insert(:owner, fantasy_team: team_b, user: other_user)
      sports_league = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: sports_league)
      player_a = insert(:fantasy_player, sports_league: sports_league)
      player_b = insert(:fantasy_player, sports_league: sports_league)
      insert(:roster_position, fantasy_player: player_b, fantasy_team: team)
      insert(:roster_position, fantasy_player: player_a, fantasy_team: team_b)

      trade =
        insert(:trade,
          status: "Proposed",
          submitted_by_team: team_b,
          submitted_by_user: other_user
        )

      insert(
        :trade_line_item,
        trade: trade,
        gaining_team: team,
        fantasy_player: player_a,
        losing_team: team_b
      )

      insert(
        :trade_line_item,
        trade: trade,
        gaining_team: team_b,
        fantasy_player: player_b,
        losing_team: team
      )

      insert(:trade_vote, trade: trade, fantasy_team: team_b, approve: true)

      attrs = %{trade_id: trade.id, approve: true}

      _conn =
        post(
          conn,
          ~p"/fantasy_teams/#{team.id}/trade_votes?#{%{trade_vote: attrs}}"
        )

      result = Repo.get_by!(TradeVote, %{trade_id: trade.id, fantasy_team_id: team.id})
      trade = Repo.get!(Trade, trade.id)

      assert result.approve == true
      assert trade.status == "Pending"
      assert_email_sent(subject: "New 338 #{league.fantasy_league_name} Trade for Approval")
    end

    test "changes Trade to Rejected if involved team votes no", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      team_b = insert(:fantasy_team, fantasy_league: league)
      user = conn.assigns.current_user
      other_user = insert(:user)
      insert(:owner, fantasy_team: team, user: user)
      insert(:owner, fantasy_team: team_b, user: other_user)
      sports_league = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: sports_league)
      player_a = insert(:fantasy_player, sports_league: sports_league)
      player_b = insert(:fantasy_player, sports_league: sports_league)
      insert(:roster_position, fantasy_player: player_b, fantasy_team: team)
      insert(:roster_position, fantasy_player: player_a, fantasy_team: team_b)

      trade =
        insert(:trade,
          status: "Proposed",
          submitted_by_team: team_b,
          submitted_by_user: other_user
        )

      insert(
        :trade_line_item,
        trade: trade,
        gaining_team: team,
        fantasy_player: player_a,
        losing_team: team_b
      )

      insert(
        :trade_line_item,
        trade: trade,
        gaining_team: team_b,
        fantasy_player: player_b,
        losing_team: team
      )

      attrs = %{trade_id: trade.id, approve: false}

      _conn =
        post(
          conn,
          ~p"/fantasy_teams/#{team.id}/trade_votes?#{%{trade_vote: attrs}}"
        )

      result = Repo.get_by!(TradeVote, %{trade_id: trade.id, fantasy_team_id: team.id})
      trade = Repo.get!(Trade, trade.id)

      assert result.approve == false
      assert trade.status == "Rejected"
      assert_email_sent(subject: "Proposed trade rejected by #{team.team_name}")
    end

    test "doesn't create if team already voted and redirects", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      team_b = insert(:fantasy_team, fantasy_league: league)
      team_c = insert(:fantasy_team, fantasy_league: league)
      user = conn.assigns.current_user
      co_owner = insert(:user)
      other_user = insert(:user)
      insert(:owner, fantasy_team: team, user: user)
      insert(:owner, fantasy_team: team, user: co_owner)
      insert(:owner, fantasy_team: team_b, user: other_user)
      sports_league = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: sports_league)
      player_a = insert(:fantasy_player, sports_league: sports_league)
      player_b = insert(:fantasy_player, sports_league: sports_league)
      insert(:roster_position, fantasy_player: player_a, fantasy_team: team_b)
      insert(:roster_position, fantasy_player: player_b, fantasy_team: team_c)
      trade = insert(:trade, submitted_by_team: team_b, submitted_by_user: other_user)

      insert(
        :trade_line_item,
        gaining_team: team_c,
        fantasy_player: player_a,
        losing_team: team_b
      )

      insert(
        :trade_line_item,
        gaining_team: team_b,
        fantasy_player: player_b,
        losing_team: team_c
      )

      insert(:trade_vote, user: co_owner, trade: trade, fantasy_team: team)
      attrs = %{trade_id: trade.id, approve: true}

      conn =
        post(
          conn,
          ~p"/fantasy_teams/#{team.id}/trade_votes?#{%{trade_vote: attrs}}"
        )

      assert html_response(conn, 302) =~ ~r/redirected/
      assert Flash.get(conn.assigns.flash, :error) == "Team has already voted"
      assert Enum.count(Repo.all(TradeVote)) == 1
    end

    test "redirects to root if user is not owner", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      team_b = insert(:fantasy_team, fantasy_league: league)
      team_c = insert(:fantasy_team, fantasy_league: league)
      other_user = insert(:user)
      insert(:owner, fantasy_team: team, user: other_user)
      sports_league = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: sports_league)
      player_a = insert(:fantasy_player, sports_league: sports_league)
      player_b = insert(:fantasy_player, sports_league: sports_league)
      insert(:roster_position, fantasy_player: player_a, fantasy_team: team_b)
      insert(:roster_position, fantasy_player: player_b, fantasy_team: team_c)
      trade = insert(:trade, submitted_by_team: team_b, submitted_by_user: other_user)

      insert(
        :trade_line_item,
        gaining_team: team_c,
        fantasy_player: player_a,
        losing_team: team_b
      )

      insert(
        :trade_line_item,
        gaining_team: team_b,
        fantasy_player: player_b,
        losing_team: team_c
      )

      attrs = %{trade_id: trade.id, approve: true}

      conn =
        post(
          conn,
          ~p"/fantasy_teams/#{team.id}/trade_votes?#{%{trade_vote: attrs}}"
        )

      assert html_response(conn, 302) =~ ~r/redirected/
      assert Flash.get(conn.assigns.flash, :error) == "You can't access that page!"
    end
  end
end
