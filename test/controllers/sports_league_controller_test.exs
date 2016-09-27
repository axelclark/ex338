defmodule Ex338.SportsLeagueControllerTest do
  use Ex338.ConnCase
  alias Ex338.{User}

  setup %{conn: conn} do
    user = %User{name: "test", email: "test@example.com", id: 1}
    {:ok, conn: assign(conn, :current_user, user), user: user}
  end

  describe "index/2" do
    test "lists all sports leagues", %{conn: conn} do
      s_league_a = insert(:sports_league)
      s_league_b = insert(:sports_league)

      conn = get conn, sports_league_path(conn, :index)

      assert html_response(conn, 200) =~ ~r/Sports Leagues/
      assert String.contains?(conn.resp_body, s_league_a.league_name)
      assert String.contains?(conn.resp_body, s_league_b.league_name)
    end
  end
end
