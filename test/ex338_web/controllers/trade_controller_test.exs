defmodule Ex338Web.TradeControllerTest do
  use Ex338Web.ConnCase

  import Swoosh.TestAssertions

  alias Ex338.DraftPicks
  alias Ex338.Trades.Trade
  alias Ex338.Trades.TradeVote

  describe "new/2" do
    setup :register_and_log_in_user

    test "renders a form to submit a trade", %{conn: conn, user: user} do
      league = insert(:fantasy_league)

      team = insert(:fantasy_team, fantasy_league: league)
      insert(:owner, fantasy_team: team, user: user)
      player_a = insert(:fantasy_player)
      insert(:roster_position, fantasy_player: player_a, fantasy_team: team)

      team_b = insert(:fantasy_team, fantasy_league: league)
      player_b = insert(:fantasy_player)
      insert(:roster_position, fantasy_player: player_b, fantasy_team: team_b)

      conn = get(conn, ~p"/fantasy_teams/#{team.id}/trades/new")

      assert html_response(conn, 200) =~ ~r/Propose a new Trade/
      assert String.contains?(conn.resp_body, team.team_name)
    end

    test "redirects to root if user is not owner", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      player_a = insert(:fantasy_player)
      _player_b = insert(:fantasy_player)
      insert(:roster_position, fantasy_player: player_a, fantasy_team: team)

      conn = get(conn, ~p"/fantasy_teams/#{team.id}/trades/new")

      assert html_response(conn, 302) =~ ~r/redirected/
    end
  end

  describe "create/2" do
    setup :register_and_log_in_user

    test "creates a trade & trade vote and redirects", %{conn: conn, user: user} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      insert(:owner, fantasy_team: team, user: user)
      team_b = insert(:fantasy_team, fantasy_league: league)
      sport = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: sport)
      insert(:championship, sports_league: sport)
      player_a = insert(:fantasy_player, sports_league: sport)
      player_b = insert(:fantasy_player, sports_league: sport)
      insert(:roster_position, fantasy_player: player_a, fantasy_team: team)
      insert(:roster_position, fantasy_player: player_b, fantasy_team: team_b)
      future_pick = insert(:future_pick, current_team: team)
      future_pick_b = insert(:future_pick, current_team: team_b)

      attrs = %{
        "additional_terms" => "more",
        "trade_line_items" => %{
          "0" => %{
            "fantasy_player_id" => player_a.id,
            "gaining_team_id" => team_b.id,
            "losing_team_id" => team.id
          },
          "1" => %{
            "fantasy_player_id" => player_b.id,
            "gaining_team_id" => team.id,
            "losing_team_id" => team_b.id
          },
          "2" => %{
            "future_pick_id" => future_pick.id,
            "gaining_team_id" => team_b.id,
            "losing_team_id" => team.id
          },
          "3" => %{
            "future_pick_id" => future_pick_b.id,
            "gaining_team_id" => team.id,
            "losing_team_id" => team_b.id
          }
        }
      }

      conn = post(conn, ~p"/fantasy_teams/#{team.id}/trades?#{[trade: attrs]}")

      %{status: status, trade_line_items: line_items} =
        Trade
        |> Trade.preload_assocs()
        |> Repo.one!()

      trade_vote = Repo.one!(TradeVote)

      assert redirected_to(conn) == ~p"/fantasy_teams/#{team.id}"
      assert status == "Proposed"
      assert Enum.count(line_items) == 4
      assert_email_sent(subject: "#{team.team_name} proposed a 338 trade")
      assert trade_vote.fantasy_team_id == team.id
      assert trade_vote.approve == true
    end

    test "returns error if invalid", %{conn: conn, user: user} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      insert(:owner, fantasy_team: team, user: user)
      team_b = insert(:fantasy_team, fantasy_league: league)
      player_a = insert(:fantasy_player)
      insert(:roster_position, fantasy_player: player_a, fantasy_team: team)
      future_pick = insert(:future_pick, current_team: team)

      attrs = %{
        "additional_terms" => "more",
        "trade_line_items" => %{
          "0" => %{
            "fantasy_player_id" => player_a.id,
            "future_pick_id" => future_pick.id,
            "gaining_team_id" => team_b.id,
            "losing_team_id" => team.id
          }
        }
      }

      conn = post(conn, ~p"/fantasy_teams/#{team.id}/trades?#{[trade: attrs]}")

      assert html_response(conn, 200) =~ "Please check the errors below."
    end

    test "redirects to root if user is not owner", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      team_b = insert(:fantasy_team, fantasy_league: league)
      player_a = insert(:fantasy_player)
      insert(:roster_position, fantasy_player: player_a, fantasy_team: team)

      attrs = %{
        "additional_terms" => "more",
        "trade_line_items" => %{
          "0" => %{
            "fantasy_player_id" => player_a.id,
            "gaining_team_id" => team_b.id,
            "losing_team_id" => team.id
          }
        }
      }

      conn = post(conn, ~p"/fantasy_teams/#{team.id}/trades?#{[trade: attrs]}")

      assert html_response(conn, 302) =~ ~r/redirected/
      assert redirected_to(conn) == "/"
    end
  end

  describe "update/2 as admin" do
    setup :register_and_log_in_admin

    test "processes an approved trade", %{conn: conn} do
      league = insert(:fantasy_league)

      team_a = insert(:fantasy_team, fantasy_league: league)
      player_a = insert(:fantasy_player)
      insert(:roster_position, fantasy_team: team_a, fantasy_player: player_a)

      team_b = insert(:fantasy_team, fantasy_league: league)
      player_b = insert(:fantasy_player)
      insert(:roster_position, fantasy_team: team_b, fantasy_player: player_b)

      trade = insert(:trade, status: "Pending", submitted_by_team: team_a)

      future_pick_a = insert(:future_pick, current_team: team_a)
      future_pick_b = insert(:future_pick, current_team: team_b)

      insert(
        :trade_line_item,
        gaining_team: team_b,
        losing_team: team_a,
        fantasy_player: player_a,
        trade: trade
      )

      insert(
        :trade_line_item,
        gaining_team: team_a,
        losing_team: team_b,
        fantasy_player: player_b,
        trade: trade
      )

      insert(
        :trade_line_item,
        gaining_team: team_b,
        losing_team: team_a,
        future_pick: future_pick_a,
        trade: trade
      )

      insert(
        :trade_line_item,
        gaining_team: team_a,
        losing_team: team_b,
        future_pick: future_pick_b,
        trade: trade
      )

      params = %{"trade" => %{"status" => "Approved"}}

      conn =
        patch(
          conn,
          Routes.fantasy_team_trade_path(
            conn,
            :update,
            team_a.id,
            trade.id,
            params
          )
        )

      assert redirected_to(conn) ==
               ~p"/fantasy_leagues/#{team_a.fantasy_league_id}/trades"

      assert Repo.get!(Trade, trade.id).status == "Approved"

      assert Repo.get_by(DraftPicks.FuturePick, %{
               id: future_pick_a.id,
               current_team_id: team_b.id
             }) !== nil
    end

    test "returns error if position is missing", %{conn: conn} do
      league = insert(:fantasy_league)

      team_a = insert(:fantasy_team, fantasy_league: league)
      player_a = insert(:fantasy_player)
      insert(:roster_position, fantasy_team: team_a, fantasy_player: player_a)

      team_b = insert(:fantasy_team, fantasy_league: league)
      player_b = insert(:fantasy_player)
      insert(:roster_position, fantasy_team: team_b, fantasy_player: player_b, status: "dropped")

      trade = insert(:trade, status: "Pending", submitted_by_team: team_a)

      insert(
        :trade_line_item,
        gaining_team: team_b,
        losing_team: team_a,
        fantasy_player: player_a,
        trade: trade
      )

      insert(
        :trade_line_item,
        gaining_team: team_a,
        losing_team: team_b,
        fantasy_player: player_b,
        trade: trade
      )

      params = %{"trade" => %{"status" => "Approved"}}

      conn =
        patch(
          conn,
          Routes.fantasy_team_trade_path(
            conn,
            :update,
            team_a.id,
            trade.id,
            params
          )
        )

      assert redirected_to(conn) ==
               ~p"/fantasy_leagues/#{team_a.fantasy_league_id}/trades"

      assert Flash.get(conn.assigns.flash, :error) == "\"One or more positions not found\""
      assert Repo.get!(Trade, trade.id).status == "Pending"
    end

    test "processes a canceled trade", %{conn: conn} do
      league = insert(:fantasy_league)

      team_a = insert(:fantasy_team, fantasy_league: league)
      insert(:owner, fantasy_team: team_a, user: conn.assigns.current_user)

      trade = insert(:trade, status: "Proposed", submitted_by_team: team_a)

      params = %{"trade" => %{"status" => "Canceled"}}

      conn =
        patch(
          conn,
          Routes.fantasy_team_trade_path(
            conn,
            :update,
            team_a.id,
            trade.id,
            params
          )
        )

      assert redirected_to(conn) ==
               ~p"/fantasy_leagues/#{team_a.fantasy_league_id}/trades"

      assert Repo.get!(Trade, trade.id).status == "Canceled"
      assert_email_sent(subject: "#{team_a.team_name} canceled its proposed 338 trade")
    end

    test "does not processes a canceled trade when already Approved", %{conn: conn} do
      league = insert(:fantasy_league)

      team_a = insert(:fantasy_team, fantasy_league: league)
      insert(:owner, fantasy_team: team_a, user: conn.assigns.current_user)

      trade = insert(:trade, status: "Approved", submitted_by_team: team_a)

      params = %{"trade" => %{"status" => "Canceled"}}

      conn =
        patch(
          conn,
          Routes.fantasy_team_trade_path(
            conn,
            :update,
            team_a.id,
            trade.id,
            params
          )
        )

      assert redirected_to(conn) == "/"
      assert Flash.get(conn.assigns.flash, :error) == "Can only update a proposed trade"
      assert Repo.get!(Trade, trade.id).status == "Approved"
    end
  end

  describe "update/2" do
    setup :register_and_log_in_user

    test "redirects to root if user is not admin and status is Approved", %{conn: conn} do
      league = insert(:fantasy_league)

      team_a = insert(:fantasy_team, fantasy_league: league)
      insert(:owner, fantasy_team: team_a, user: conn.assigns.current_user)

      trade = insert(:trade, status: "Pending", submitted_by_team: team_a)

      params = %{"trade" => %{"status" => "Approved"}}

      conn =
        patch(
          conn,
          Routes.fantasy_team_trade_path(
            conn,
            :update,
            team_a.id,
            trade.id,
            params
          )
        )

      assert redirected_to(conn) == "/"
    end

    test "does not processes a canceled trade when user not owner or admin", %{conn: conn} do
      league = insert(:fantasy_league)

      team_a = insert(:fantasy_team, fantasy_league: league)
      player_a = insert(:fantasy_player)
      insert(:roster_position, fantasy_team: team_a, fantasy_player: player_a)

      team_b = insert(:fantasy_team, fantasy_league: league)
      player_b = insert(:fantasy_player)
      insert(:roster_position, fantasy_team: team_b, fantasy_player: player_b)

      trade = insert(:trade, status: "Proposed", submitted_by_team: team_a)

      insert(
        :trade_line_item,
        gaining_team: team_b,
        losing_team: team_a,
        fantasy_player: player_a,
        trade: trade
      )

      insert(
        :trade_line_item,
        gaining_team: team_a,
        losing_team: team_b,
        fantasy_player: player_b,
        trade: trade
      )

      params = %{"trade" => %{"status" => "Canceled"}}

      conn =
        patch(
          conn,
          Routes.fantasy_team_trade_path(
            conn,
            :update,
            team_a.id,
            trade.id,
            params
          )
        )

      assert redirected_to(conn) == "/"

      assert Repo.get!(Trade, trade.id).status == "Proposed"
    end
  end
end
