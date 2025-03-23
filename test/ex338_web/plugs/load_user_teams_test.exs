defmodule Ex338Web.LoadUserTeamsTest do
  use Ex338Web.ConnCase

  alias Ex338Web.LoadUserTeams

  @opts LoadUserTeams.init([])

  test "preloads all current user teams into assigns" do
    user = insert(:user)
    league = insert(:fantasy_league)
    team = insert(:fantasy_team, fantasy_league: league)
    insert(:owner, fantasy_team: team, user: user)

    conn =
      assign(build_conn(), :current_user, user)

    conn = LoadUserTeams.call(conn, @opts)

    [result] = conn.assigns.current_user.fantasy_teams

    assert result.id == team.id
  end

  test "handles no current user" do
    conn = build_conn()

    conn = LoadUserTeams.call(conn, @opts)

    assert conn == conn
  end
end
