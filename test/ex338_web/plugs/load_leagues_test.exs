defmodule Ex338Web.LoadLeaguesTest do
  use Ex338Web.ConnCase
  use Plug.Test

  alias Ex338Web.{LoadLeagues}

  @opts LoadLeagues.init([])

  test "loads all Fantasy Leagues into assigns" do
    league = insert(:fantasy_league)
    conn = build_conn()

    conn = LoadLeagues.call(conn, @opts)

    assert conn.assigns.leagues == [league]
  end
end
