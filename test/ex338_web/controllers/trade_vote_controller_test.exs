defmodule Ex338Web.TradeVoteControllerTest do
  use Ex338Web.ConnCase
  alias Ex338.{TradeVote, Repo, User}

  setup %{conn: conn} do
    user = %User{name: "test", email: "test@example.com", id: 1}
    {:ok, conn: assign(conn, :current_user, user), user: user}
  end

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
      trade =
        insert(:trade, submitted_by_team: team_b, submitted_by_user: other_user)
      insert(
        :trade_line_item,
        gaining_team: team_c, fantasy_player: player_a, losing_team: team_b
      )
      insert(
        :trade_line_item,
        gaining_team: team_b, fantasy_player: player_b, losing_team: team_c
      )
      attrs = %{trade_id: trade.id, approve: true}

      conn = post(
        conn,
        fantasy_team_trade_vote_path(conn, :create, team.id, trade_vote: attrs)
      )

      result =
        Repo.get_by!(TradeVote, %{trade_id: trade.id, fantasy_team_id: team.id})

      assert result.fantasy_team_id == team.id
      assert result.user_id == user.id
      assert result.approve == true
      assert redirected_to(conn) ==
        fantasy_league_trade_path(conn, :index, league.id)
    end
  end
end
