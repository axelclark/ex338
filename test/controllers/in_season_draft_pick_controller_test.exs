defmodule Ex338Web.InSeasonDraftPickControllerTest do
  use Ex338Web.ConnCase

  alias Ex338.{User, Repo, InSeasonDraftPick}

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
      pick_asset =
        insert(:roster_position, fantasy_team: team, fantasy_player: player)
      pick =
        insert(:in_season_draft_pick, position: 1, draft_pick_asset: pick_asset)

      conn = get conn, in_season_draft_pick_path(conn, :edit, pick.id)

      assert html_response(conn, 200) =~ ~r/Draft Pick/
    end

    test "redirects to root if user is not owner", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)

      player = insert(:fantasy_player, draft_pick: true)
      pick_asset =
        insert(:roster_position, fantasy_team: team, fantasy_player: player)
      pick =
        insert(:in_season_draft_pick, position: 1, draft_pick_asset: pick_asset)

      conn = get conn, in_season_draft_pick_path(conn, :edit, pick.id)

      assert html_response(conn, 302) =~ ~r/redirected/
    end
  end

  describe "update/2" do
    test "updates an in season draft pick and redirects", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      insert(:owner, fantasy_team: team, user: conn.assigns.current_user)

      championship = insert(:championship)
      pick_player = insert(:fantasy_player, draft_pick: true)
      player = insert(:fantasy_player, draft_pick: false)
      pick_asset =
        insert(:roster_position, fantasy_team: team, fantasy_player: pick_player)
      pick =
        insert(:in_season_draft_pick, position: 1, draft_pick_asset: pick_asset,
          championship: championship)

      conn = patch conn, in_season_draft_pick_path(conn, :update, pick.id,
               in_season_draft_pick: %{drafted_player_id: player.id})

      assert Repo.get!(InSeasonDraftPick, pick.id).drafted_player_id == player.id
      assert redirected_to(conn) ==
        fantasy_league_championship_path(conn, :show, league.id, championship.id)
    end

    test "does not update and renders errors when invalid", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      insert(:owner, fantasy_team: team, user: conn.assigns.current_user)

      player = insert(:fantasy_player, draft_pick: true)
      pick_asset =
        insert(:roster_position, fantasy_team: team, fantasy_player: player)
      pick =
        insert(:in_season_draft_pick, position: 1, draft_pick_asset: pick_asset)

      conn = patch conn, in_season_draft_pick_path(conn, :update, pick.id,
               in_season_draft_pick: %{drafted_player_id: nil})

      assert html_response(conn, 200) =~ "Please check the errors below."
    end

    test "redirects to root if user is not owner", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)

      player = insert(:fantasy_player, draft_pick: true)
      pick_asset =
        insert(:roster_position, fantasy_team: team, fantasy_player: player)
      pick =
        insert(:in_season_draft_pick, position: 1, draft_pick_asset: pick_asset)

      conn = patch conn, in_season_draft_pick_path(conn, :update, pick.id,
               in_season_draft_pick: %{drafted_player_id: nil})

      assert html_response(conn, 302) =~ ~r/redirected/
    end
  end
end
