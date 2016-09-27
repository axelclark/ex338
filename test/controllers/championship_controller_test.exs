defmodule Ex338.ChampionshipControllerTest do
  use Ex338.ConnCase
  alias Ex338.{User}

  setup %{conn: conn} do
    user = %User{name: "test", email: "test@example.com", id: 1}
    {:ok, conn: assign(conn, :current_user, user), user: user}
  end

  describe "index/2" do
    test "lists all championships", %{conn: conn} do
      f_league = insert(:fantasy_league, year: 2017)
      s_league_a = insert(:sports_league)
      s_league_b = insert(:sports_league)
      championship_a = insert(:championship, sports_league: s_league_a)
      championship_b = insert(:championship, sports_league: s_league_b)

      conn = get conn, fantasy_league_championship_path(conn, :index, f_league.id)

      assert html_response(conn, 200) =~ ~r/Championships/
      assert String.contains?(conn.resp_body, championship_a.title)
      assert String.contains?(conn.resp_body, championship_b.title)
      assert String.contains?(conn.resp_body, championship_b.sports_league.abbrev)
    end
  end
end
