defmodule Ex338Web.InSeasonDraftPickControllerTest do
  use Ex338Web.ConnCase

  alias Ex338.Accounts.User
  alias Ex338.DraftQueues.DraftQueue
  alias Ex338.InSeasonDraftPicks.InSeasonDraftPick
  alias Ex338.Repo

  setup %{conn: conn} do
    user = %User{name: "test", email: "test@example.com", id: 1}
    {:ok, conn: assign(conn, :current_user, user), user: user}
  end

  describe "edit/2" do
    test "renders a form to submit a in season draft pick", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      insert(:owner, fantasy_team: team, user: conn.assigns.current_user)

      player = insert(:fantasy_player, draft_pick: true)
      pick_asset = insert(:roster_position, fantasy_team: team, fantasy_player: player)
      pick = insert(:in_season_draft_pick, position: 1, draft_pick_asset: pick_asset)

      conn = get(conn, in_season_draft_pick_path(conn, :edit, pick.id))

      assert html_response(conn, 200) =~ ~r/Draft Pick/
    end

    test "redirects to root if user is not owner", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)

      player = insert(:fantasy_player, draft_pick: true)
      pick_asset = insert(:roster_position, fantasy_team: team, fantasy_player: player)
      pick = insert(:in_season_draft_pick, position: 1, draft_pick_asset: pick_asset)

      conn = get(conn, in_season_draft_pick_path(conn, :edit, pick.id))

      assert html_response(conn, 302) =~ ~r/redirected/
    end
  end

  describe "update/2" do
    test "updates an in season draft pick and redirects", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      insert(:owner, fantasy_team: team, user: conn.assigns.current_user)

      sport = insert(:sports_league)
      championship = insert(:championship, sports_league: sport)
      pick_player = insert(:fantasy_player, draft_pick: true, sports_league: sport)
      player = insert(:fantasy_player, draft_pick: false, sports_league: sport)
      drafted_queue = insert(:draft_queue, fantasy_team: team, fantasy_player: player)
      pick_asset = insert(:roster_position, fantasy_team: team, fantasy_player: pick_player)

      pick =
        insert(
          :in_season_draft_pick,
          position: 1,
          draft_pick_asset: pick_asset,
          championship: championship
        )

      team2 = insert(:fantasy_team, fantasy_league: league)

      unavailable_queue =
        insert(:draft_queue, fantasy_team: team2, fantasy_player: player, order: 1)

      conn =
        patch(
          conn,
          in_season_draft_pick_path(
            conn,
            :update,
            pick.id,
            in_season_draft_pick: %{drafted_player_id: player.id}
          )
        )

      assert Repo.get!(InSeasonDraftPick, pick.id).drafted_player_id == player.id

      assert redirected_to(conn) ==
               fantasy_league_championship_path(conn, :show, league.id, championship.id)

      assert Repo.get!(DraftQueue, unavailable_queue.id).status == :unavailable
      assert Repo.get!(DraftQueue, drafted_queue.id).status == :drafted
    end

    test "does not update and renders errors when invalid", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      insert(:owner, fantasy_team: team, user: conn.assigns.current_user)

      player = insert(:fantasy_player, draft_pick: true)
      pick_asset = insert(:roster_position, fantasy_team: team, fantasy_player: player)
      pick = insert(:in_season_draft_pick, position: 1, draft_pick_asset: pick_asset)

      conn =
        patch(
          conn,
          in_season_draft_pick_path(
            conn,
            :update,
            pick.id,
            in_season_draft_pick: %{drafted_player_id: nil}
          )
        )

      assert html_response(conn, 200) =~ "Please check the errors below."
    end

    test "redirects to root if user is not owner", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)

      player = insert(:fantasy_player, draft_pick: true)
      pick_asset = insert(:roster_position, fantasy_team: team, fantasy_player: player)
      pick = insert(:in_season_draft_pick, position: 1, draft_pick_asset: pick_asset)

      conn =
        patch(
          conn,
          in_season_draft_pick_path(
            conn,
            :update,
            pick.id,
            in_season_draft_pick: %{drafted_player_id: nil}
          )
        )

      assert html_response(conn, 302) =~ ~r/redirected/
    end
  end
end
