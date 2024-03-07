defmodule Ex338Web.ChampionshipSlotAdminControllerTest do
  use Ex338Web.ConnCase

  alias Ex338.Accounts.User
  alias Ex338.Championships.ChampionshipSlot

  setup %{conn: conn} do
    user = %User{name: "test", email: "test@example.com", id: 1}
    {:ok, conn: assign(conn, :current_user, user), user: user}
  end

  describe "create/2" do
    test "admin creates roster slots for a championship", %{conn: conn} do
      conn = put_in(conn.assigns.current_user.admin, true)
      league = insert(:fantasy_league)
      sport = insert(:sports_league)
      other_sport = insert(:sports_league)
      championship = insert(:championship, category: "event", sports_league: sport)
      _other_championship = insert(:championship, category: "event", sports_league: other_sport)
      player_a = insert(:fantasy_player, sports_league: sport)
      player_b = insert(:fantasy_player, sports_league: sport)
      player_c = insert(:fantasy_player, sports_league: sport)
      other_player = insert(:fantasy_player, sports_league: other_sport)
      team = insert(:fantasy_team, fantasy_league: league)
      insert(:roster_position, fantasy_player: player_a, fantasy_team: team, status: "active")
      insert(:roster_position, fantasy_player: player_b, fantasy_team: team, status: "active")
      insert(:roster_position, fantasy_player: player_c, fantasy_team: team, status: "traded")
      insert(:roster_position, fantasy_player: other_player, fantasy_team: team, status: "active")
      attrs = %{championship_id: Integer.to_string(championship.id)}

      conn =
        post(conn, ~p"/fantasy_leagues/#{league.id}/championship_slot_admin", attrs)

      results = Repo.all(ChampionshipSlot)

      assert Enum.count(results) == 2

      assert redirected_to(conn) ==
               ~p"/fantasy_leagues/#{league.id}/championships/#{championship.id}"
    end

    test "redirects to root if user is not admin", %{conn: conn} do
      league = insert(:fantasy_league)
      championship = insert(:championship, category: "event")
      attrs = %{championship_id: championship.id}

      conn =
        post(conn, ~p"/fantasy_leagues/#{league.id}/championship_slot_admin", attrs)

      assert html_response(conn, 302) =~ ~r/redirected/
    end
  end
end
