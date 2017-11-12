defmodule Ex338Web.TradeControllerTest do
  use Ex338Web.ConnCase

  alias Ex338.{Trade}

  setup %{conn: conn} do
    user = %Ex338.User{name: "test", email: "test@example.com", id: 1}
    {:ok, conn: assign(conn, :current_user, user), user: user}
  end

  describe "index/2" do
    test "lists all trades in a league", %{conn: conn} do
      player = insert(:fantasy_player)

      league = insert(:fantasy_league)
      team_a = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      team_b = insert(:fantasy_team, team_name: "Axel", fantasy_league: league)
      trade = insert(:trade)
      insert(:trade_line_item, trade: trade, gaining_team: team_a,
        losing_team: team_b, fantasy_player: player)

      other_league = insert(:fantasy_league)
      team_c = insert(:fantasy_team, team_name: "Another Team",
        fantasy_league: other_league)
      team_d = insert(:fantasy_team, team_name: "Other Team",
        fantasy_league: other_league)
      other_trade = insert(:trade)
      insert(:trade_line_item, trade: other_trade, gaining_team: team_c,
        losing_team: team_d, fantasy_player: player)

      conn = get conn, fantasy_league_trade_path(conn, :index, league.id)

      assert html_response(conn, 200) =~ ~r/Trades/
      assert String.contains?(conn.resp_body, team_a.team_name)
      assert String.contains?(conn.resp_body, team_b.team_name)
      assert String.contains?(conn.resp_body, player.player_name)
      refute String.contains?(conn.resp_body, team_c.team_name)
    end
  end

  describe "new/2" do
    test "renders a form to submit a trade", %{conn: conn} do
      league = insert(:fantasy_league)

      team = insert(:fantasy_team, fantasy_league: league)
      insert(:owner, fantasy_team: team, user: conn.assigns.current_user)
      player_a = insert(:fantasy_player)
      insert(:roster_position, fantasy_player: player_a, fantasy_team: team)

      team_b = insert(:fantasy_team, fantasy_league: league)
      player_b = insert(:fantasy_player)
      insert(:roster_position, fantasy_player: player_b, fantasy_team: team_b)

      conn = get conn, fantasy_team_trade_path(conn, :new, team.id)

      assert html_response(conn, 200) =~ ~r/Submit New Trade/
      assert String.contains?(conn.resp_body, team.team_name)
    end

    test "redirects to root if user is not owner", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      player_a = insert(:fantasy_player)
      _player_b = insert(:fantasy_player)
      insert(:roster_position, fantasy_player: player_a, fantasy_team: team)

      conn = get conn, fantasy_team_trade_path(conn, :new, team.id)

      assert html_response(conn, 302) =~ ~r/redirected/
    end
  end

  describe "create/2" do
    test "creates a trade and redirects", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      insert(:owner, fantasy_team: team, user: conn.assigns.current_user)
      team_b = insert(:fantasy_team, fantasy_league: league)
      player_a = insert(:fantasy_player)
      player_b = insert(:fantasy_player)
      player_c = insert(:fantasy_player)
      player_d = insert(:fantasy_player)
      insert(:roster_position, fantasy_player: player_a, fantasy_team: team)
      insert(:roster_position, fantasy_player: player_b, fantasy_team: team_b)
      insert(:roster_position, fantasy_player: player_c, fantasy_team: team)
      insert(:roster_position, fantasy_player: player_d, fantasy_team: team_b)

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
            "fantasy_player_id" => player_c.id,
            "gaining_team_id" => team_b.id,
            "losing_team_id" => team.id
          },
          "3" => %{
            "fantasy_player_id" => player_d.id,
            "gaining_team_id" => team.id,
            "losing_team_id" => team_b.id
          },
        }
      }

      conn =
        post conn, fantasy_team_trade_path(conn, :create, team.id, trade: attrs)

      [%{trade_line_items: line_items}] =
        Trade
        |> preload(:trade_line_items)
        |> Repo.all

      assert redirected_to(conn) == fantasy_team_path(conn, :show, team.id)
      assert Enum.count(line_items) == 4
    end

    test "redirects to root if user is not owner", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      team_b = insert(:fantasy_team, fantasy_league: league)
      player_a = insert(:fantasy_player)
      player_b = insert(:fantasy_player)
      player_c = insert(:fantasy_player)
      player_d = insert(:fantasy_player)
      insert(:roster_position, fantasy_player: player_a, fantasy_team: team)
      insert(:roster_position, fantasy_player: player_b, fantasy_team: team_b)
      insert(:roster_position, fantasy_player: player_c, fantasy_team: team)
      insert(:roster_position, fantasy_player: player_d, fantasy_team: team_b)

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
            "fantasy_player_id" => player_c.id,
            "gaining_team_id" => team_b.id,
            "losing_team_id" => team.id
          },
          "3" => %{
            "fantasy_player_id" => player_d.id,
            "gaining_team_id" => team.id,
            "losing_team_id" => team_b.id
          },
        }
      }

      conn =
        post conn, fantasy_team_trade_path(conn, :create, team.id, trade: attrs)

      assert html_response(conn, 302) =~ ~r/redirected/
    end
  end
end
