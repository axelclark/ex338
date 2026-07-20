defmodule Ex338Web.LoadLeaguesTest do
  use Ex338Web.ConnCase

  alias Ex338Web.LoadLeagues

  @opts LoadLeagues.init([])

  test "loads all Fantasy Leagues into assigns" do
    league = insert(:fantasy_league)
    conn = build_conn()

    conn = LoadLeagues.call(conn, @opts)

    assert conn.assigns.leagues == [league]
  end

  test "hides private leagues from a non-member" do
    public = insert(:fantasy_league, private?: false)
    insert(:fantasy_league, private?: true)
    conn = assign(build_conn(), :current_user, insert(:user))

    conn = LoadLeagues.call(conn, @opts)

    assert conn.assigns.leagues == [public]
  end

  test "keeps private leagues for a member" do
    public = insert(:fantasy_league, private?: false)
    private = insert(:fantasy_league, private?: true)
    team = insert(:fantasy_team, fantasy_league: private)
    member = insert(:user)
    insert(:owner, fantasy_team: team, user: member)
    conn = assign(build_conn(), :current_user, member)

    conn = LoadLeagues.call(conn, @opts)

    assert Enum.sort_by(conn.assigns.leagues, & &1.id) ==
             Enum.sort_by([public, private], & &1.id)
  end
end
