defmodule Ex338Web.DraftQueueControllerTest do
  use Ex338Web.ConnCase

  alias Ex338.{User, DraftQueue}

  setup %{conn: conn} do
    user = %User{name: "test", email: "test@example.com", id: 1}
    {:ok, conn: assign(conn, :current_user, user), user: user}
  end

  describe "new/2" do
    test "renders a form to submit a new draft queue", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      insert(:owner, fantasy_team: team, user: conn.assigns.current_user)
      sport = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: sport)
      insert(:championship, sports_league: sport)
      player = insert(:fantasy_player, sports_league: sport)

      conn = get(conn, fantasy_team_draft_queue_path(conn, :new, team.id))

      assert html_response(conn, 200) =~ ~r/Submit New Player For Queue/
      assert String.contains?(conn.resp_body, player.player_name)
    end

    test "redirects to root if user is not owner", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      sport = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: sport)
      insert(:fantasy_player, sports_league: sport)

      conn = get(conn, fantasy_team_draft_queue_path(conn, :new, team.id))

      assert html_response(conn, 302) =~ ~r/redirected/
    end
  end

  describe "create/2" do
    test "creates a draft queue and redirects", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      insert(:owner, fantasy_team: team, user: conn.assigns.current_user)
      sport = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: sport)
      insert(:championship, sports_league: sport)
      player = insert(:fantasy_player, sports_league: sport)
      attrs = %{fantasy_player_id: player.id}

      conn =
        post(
          conn,
          fantasy_team_draft_queue_path(conn, :create, team.id, draft_queue: attrs)
        )

      result = Repo.one(DraftQueue)

      assert result.fantasy_team_id == team.id
      assert result.status == :pending
      assert result.fantasy_player_id == player.id
      assert redirected_to(conn) == fantasy_team_path(conn, :show, team.id)
    end

    test "does not update and renders errors when invalid", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      insert(:owner, fantasy_team: team, user: conn.assigns.current_user)
      sport = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: sport)
      insert(:championship, sports_league: sport)
      _player = insert(:fantasy_player, sports_league: sport)
      attrs = %{fantasy_player_id: ""}

      conn =
        post(
          conn,
          fantasy_team_draft_queue_path(conn, :create, team.id, draft_queue: attrs)
        )

      assert html_response(conn, 200) =~ "Please check the errors below."
    end

    test "redirects to root if user is not owner", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      sport = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: sport)
      insert(:championship, sports_league: sport)
      player = insert(:fantasy_player, sports_league: sport)
      attrs = %{fantasy_player_id: player.id}

      conn =
        post(
          conn,
          fantasy_team_draft_queue_path(conn, :create, team.id, draft_queue: attrs)
        )

      assert html_response(conn, 302) =~ ~r/redirected/
    end
  end
end
