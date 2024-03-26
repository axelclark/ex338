defmodule Ex338Web.FantasyTeamDraftQueuesLive.EditTest do
  @moduledoc false
  use Ex338Web.ConnCase

  import Phoenix.LiveViewTest

  setup :register_and_log_in_user

  describe "Edit Fantasy Team Draft Queues Form" do
    test "updates a fantasy team's draft queues and redirects", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      insert(:owner, fantasy_team: team, user: conn.assigns.current_user)
      queue = insert(:draft_queue, fantasy_team: team)

      {:ok, view, _html} = live(conn, ~p"/fantasy_teams/#{team.id}/draft_queues/edit")

      attrs = %{
        "draft_queues" => %{
          "0" => %{"id" => queue.id}
        },
        "draft_queues_order" => ["0"]
      }

      view
      |> form("#fantasy-team-draft-queues-form", fantasy_team: attrs)
      |> render_submit()

      {path, _flash} = assert_redirect(view)
      assert path == ~p"/fantasy_teams/#{team}"
    end

    test "does not update and renders draft queue errors when invalid", %{conn: conn} do
      league = insert(:fantasy_league, max_flex_spots: 1)
      team = insert(:fantasy_team, fantasy_league: league)
      insert(:owner, fantasy_team: team, user: conn.assigns.current_user)

      regular_position = insert(:roster_position, fantasy_team: team)
      flex_sport = regular_position.fantasy_player.sports_league

      [add, plyr] = insert_list(2, :fantasy_player, sports_league: flex_sport)
      queue = insert(:draft_queue, fantasy_team: team, fantasy_player: add, order: 1)
      insert(:roster_position, fantasy_team: team, fantasy_player: plyr)

      {:ok, view, _html} = live(conn, ~p"/fantasy_teams/#{team.id}/draft_queues/edit")

      attrs = %{
        "draft_queues" => %{
          "0" => %{"id" => queue.id}
        },
        "draft_queues_order" => ["0"]
      }

      html =
        view
        |> form("#fantasy-team-draft-queues-form", fantasy_team: attrs)
        |> render_submit()

      assert html =~ "No flex position available for this player"
    end

    test "redirects to root if user is not owner", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)

      {:error, {:live_redirect, %{to: path}}} =
        live(conn, ~p"/fantasy_teams/#{team.id}/draft_queues/edit")

      assert path == ~p"/fantasy_teams/#{team.id}"
    end
  end

  describe "New Draft Queue Form" do
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

      {:ok, view, html} = live(conn, ~p"/fantasy_teams/#{team.id}/draft_queues/edit")

      assert html =~ "Submit new Draft Queue"
      assert html =~ player_a.player_name
      assert html =~ player_b.player_name

      attrs = %{fantasy_player_id: player_a.id}

      view
      |> form("#new-draft-queue-form", draft_queue: attrs)
      |> render_submit()

      assert has_element?(view, "td", player_a.player_name)
    end

    test "does not update and renders draft queue errors when invalid", %{conn: conn} do
      league = insert(:fantasy_league, max_flex_spots: 1)
      team = insert(:fantasy_team, fantasy_league: league)
      insert(:owner, fantasy_team: team, user: conn.assigns.current_user)

      regular_position = insert(:roster_position, fantasy_team: team)
      flex_sport = regular_position.fantasy_player.sports_league

      [add, plyr] = insert_list(2, :fantasy_player, sports_league: flex_sport)
      insert(:roster_position, fantasy_team: team, fantasy_player: plyr)

      insert(:league_sport, fantasy_league: league, sports_league: flex_sport)
      insert(:championship, sports_league: flex_sport)

      {:ok, view, _html} = live(conn, ~p"/fantasy_teams/#{team.id}/draft_queues/edit")

      attrs = %{fantasy_player_id: add.id}

      html =
        view
        |> form("#new-draft-queue-form", draft_queue: attrs)
        |> render_submit()

      assert html =~ "No flex position available for this player"
    end

    test "renders a form with only players from the fantasy league's sport draft", %{conn: conn} do
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

      {:ok, _view, html} = live(conn, ~p"/fantasy_teams/#{team.id}/draft_queues/edit")

      assert html =~ "Submit new Draft Queue"
      assert html =~ player_a.player_name
      refute html =~ player_b.player_name
    end
  end
end
