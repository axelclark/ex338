defmodule Ex338Web.DraftQueueControllerTest do
  use Ex338Web.ConnCase

  alias Ex338.Accounts.User
  alias Ex338.DraftQueues.DraftQueue

  setup %{conn: conn} do
    user = %User{name: "test", email: "test@example.com", id: 1}
    {:ok, conn: assign(conn, :current_user, user), user: user}
  end

  describe "new/2" do
    test "renders a form to submit a new draft queue", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      insert(:owner, fantasy_team: team, user: conn.assigns.current_user)

      sport_a = insert(:sports_league)
      player_a = insert(:fantasy_player, sports_league: sport_a)
      insert(:league_sport, fantasy_league: league, sports_league: sport_a)
      insert(:championship, sports_league: sport_a)

      sport_b = insert(:sports_league)
      player_b = insert(:fantasy_player, sports_league: sport_b)
      insert(:league_sport, sports_league: sport_b, fantasy_league: league)
      insert(:championship, sports_league: sport_b)

      conn = get(conn, ~p"/fantasy_teams/#{team.id}/draft_queues/new")

      assert html_response(conn, 200) =~ ~r/Submit new Draft Queue/
      assert String.contains?(conn.resp_body, player_a.player_name)
      assert String.contains?(conn.resp_body, player_b.player_name)
    end

    test "renders a form with only players from sport draft", %{conn: conn} do
      sport_a = insert(:sports_league)
      league = insert(:fantasy_league, sport_draft: sport_a)

      team = insert(:fantasy_team, fantasy_league: league)
      insert(:owner, fantasy_team: team, user: conn.assigns.current_user)

      player_a = insert(:fantasy_player, sports_league: sport_a)
      insert(:league_sport, fantasy_league: league, sports_league: sport_a)
      insert(:championship, sports_league: sport_a)

      sport_b = insert(:sports_league)
      player_b = insert(:fantasy_player, sports_league: sport_b)
      insert(:league_sport, sports_league: sport_b, fantasy_league: league)
      insert(:championship, sports_league: sport_b)

      conn = get(conn, ~p"/fantasy_teams/#{team.id}/draft_queues/new")

      assert html_response(conn, 200) =~ ~r/Submit new Draft Queue/
      assert String.contains?(conn.resp_body, player_a.player_name)
      refute String.contains?(conn.resp_body, player_b.player_name)
    end

    test "redirects to root if user is not owner", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      sport = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: sport)
      insert(:fantasy_player, sports_league: sport)

      conn = get(conn, ~p"/fantasy_teams/#{team.id}/draft_queues/new")

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
          ~p"/fantasy_teams/#{team.id}/draft_queues?#{[draft_queue: attrs]}"
        )

      result = Repo.one(DraftQueue)

      assert result.fantasy_team_id == team.id
      assert result.status == :pending
      assert result.fantasy_player_id == player.id
      assert redirected_to(conn) == ~p"/fantasy_teams/#{team.id}"
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
          ~p"/fantasy_teams/#{team.id}/draft_queues?#{[draft_queue: attrs]}"
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
          ~p"/fantasy_teams/#{team.id}/draft_queues?#{[draft_queue: attrs]}"
        )

      assert html_response(conn, 302) =~ ~r/redirected/
    end
  end
end
