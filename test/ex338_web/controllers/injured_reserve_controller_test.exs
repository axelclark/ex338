defmodule Ex338Web.InjuredReserveControllerTest do
  use Ex338Web.ConnCase
  alias Ex338.{Accounts.User, InjuredReserves.InjuredReserve}

  setup %{conn: conn} do
    user = %User{name: "test", email: "test@example.com", id: 1}
    {:ok, conn: assign(conn, :current_user, user), user: user}
  end

  describe "index/2" do
    test "lists all injured reserve transactions in a league", %{conn: conn} do
      league = insert(:fantasy_league)
      other_league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      player = insert(:fantasy_player)

      other_team =
        insert(
          :fantasy_team,
          team_name: "Another Team",
          fantasy_league: other_league
        )

      insert(
        :injured_reserve,
        fantasy_team: team,
        injured_player: player,
        status: "approved"
      )

      insert(
        :injured_reserve,
        fantasy_team: other_team,
        injured_player: player,
        status: "approved"
      )

      conn = get(conn, fantasy_league_injured_reserve_path(conn, :index, league.id))

      assert html_response(conn, 200) =~ ~r/Injured Reserve Actions/
      assert String.contains?(conn.resp_body, team.team_name)
      assert String.contains?(conn.resp_body, player.player_name)
      refute String.contains?(conn.resp_body, other_team.team_name)
    end
  end

  describe "new/2" do
    test "renders a form to submit an injured reserve", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      insert(:owner, fantasy_team: team, user: conn.assigns.current_user)
      player_a = insert(:fantasy_player)
      insert(:roster_position, fantasy_player: player_a, fantasy_team: team, status: "active")
      sport = insert(:sports_league)
      player_b = insert(:fantasy_player, sports_league: sport)
      insert(:league_sport, sports_league: sport, fantasy_league: league)
      insert(:championship, sports_league: sport)

      other_team = insert(:fantasy_team, fantasy_league: league)
      other_player = insert(:fantasy_player, sports_league: sport)

      insert(:roster_position,
        fantasy_player: other_player,
        fantasy_team: other_team,
        status: "active"
      )

      conn = get(conn, fantasy_team_injured_reserve_path(conn, :new, team.id))

      assert html_response(conn, 200) =~ ~r/Submit a new Injured Reserve/
      assert String.contains?(conn.resp_body, team.team_name)
      assert String.contains?(conn.resp_body, player_a.player_name)
      assert String.contains?(conn.resp_body, player_b.player_name)
      refute String.contains?(conn.resp_body, other_player.player_name)
    end

    test "redirects to root if user is not owner", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      player_a = insert(:fantasy_player)
      insert(:roster_position, fantasy_player: player_a, fantasy_team: team)

      conn = get(conn, fantasy_team_injured_reserve_path(conn, :new, team.id))

      assert html_response(conn, 302) =~ ~r/redirected/
    end
  end

  describe "update/2" do
    test "processes an approved IR claim", %{conn: conn} do
      conn = put_in(conn.assigns.current_user.admin, true)
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      player_a = insert(:fantasy_player)
      player_b = insert(:fantasy_player)
      insert(:roster_position, fantasy_team: team, fantasy_player: player_a)

      ir =
        insert(
          :injured_reserve,
          injured_player: player_a,
          fantasy_team: team,
          replacement_player: player_b,
          status: "submitted"
        )

      conn =
        patch(
          conn,
          fantasy_league_injured_reserve_path(conn, :update, league.id, ir.id, %{
            "injured_reserve" => %{"status" => "approved"}
          })
        )

      assert redirected_to(conn) ==
               fantasy_league_injured_reserve_path(
                 conn,
                 :index,
                 team.fantasy_league_id
               )

      assert Repo.get!(InjuredReserve, ir.id).status == :approved
    end

    test "handles error", %{conn: conn} do
      conn = put_in(conn.assigns.current_user.admin, true)
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      player_a = insert(:fantasy_player)
      player_b = insert(:fantasy_player)

      ir =
        insert(
          :injured_reserve,
          injured_player: player_a,
          fantasy_team: team,
          replacement_player: player_b,
          status: "submitted"
        )

      conn =
        patch(
          conn,
          fantasy_league_injured_reserve_path(conn, :update, league.id, ir.id, %{
            "injured_reserve" => %{"status" => "approved"}
          })
        )

      assert get_flash(conn, :error) == "No roster position found for IR."
      assert Repo.get!(InjuredReserve, ir.id).status == :submitted
    end

    test "redirects to root if user is not admin", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      ir = insert(:injured_reserve, fantasy_team: team)

      conn =
        patch(
          conn,
          fantasy_league_injured_reserve_path(conn, :update, league.id, ir.id, %{
            "injured_reserve" => %{"status" => "approved"}
          })
        )

      assert get_flash(conn, :error) == "You are not authorized"
      assert html_response(conn, 302) =~ ~r/redirected/
    end
  end
end
