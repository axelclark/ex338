defmodule Ex338Web.WaiverAdminControllerTest do
  use Ex338Web.ConnCase

  alias Ex338.FantasyTeams.FantasyTeam
  alias Ex338.RosterPositions.RosterPosition
  alias Ex338.Waivers.Waiver

  describe "edit/2" do
    setup :register_and_log_in_admin

    test "renders a form for admin to process a waiver", %{conn: conn} do
      team = insert(:fantasy_team, waiver_position: 1)
      player_a = insert(:fantasy_player)
      player_b = insert(:fantasy_player)

      waiver =
        insert(
          :waiver,
          fantasy_team: team,
          drop_fantasy_player: player_a,
          add_fantasy_player: player_b
        )

      conn = get(conn, ~p"/waiver_admin/#{waiver.id}/edit")

      assert html_response(conn, 200) =~ ~r/Process Waiver/
      assert String.contains?(conn.resp_body, team.team_name)
      assert String.contains?(conn.resp_body, "1")
      assert String.contains?(conn.resp_body, player_a.player_name)
      assert String.contains?(conn.resp_body, player_b.player_name)
    end
  end

  describe "update/2" do
    setup :register_and_log_in_admin

    test "processes a successful waiver", %{conn: conn} do
      league = insert(:fantasy_league)
      team_a = insert(:fantasy_team, waiver_position: 2, fantasy_league: league)
      team_b = insert(:fantasy_team, waiver_position: 1, fantasy_league: league)
      team_c = insert(:fantasy_team, waiver_position: 3, fantasy_league: league)
      player_a = insert(:fantasy_player)
      player_b = insert(:fantasy_player)

      position =
        insert(
          :roster_position,
          fantasy_team: team_a,
          fantasy_player: player_a
        )

      waiver =
        insert(
          :waiver,
          fantasy_team: team_a,
          drop_fantasy_player: player_a,
          add_fantasy_player: player_b
        )

      params = %{status: "successful"}

      conn =
        patch(conn, ~p"/waiver_admin/#{waiver.id}", waiver: params)

      assert redirected_to(conn) ==
               ~p"/fantasy_leagues/#{team_a.fantasy_league_id}/waivers"

      assert Repo.get!(Waiver, waiver.id).status == "successful"
      assert Repo.get!(RosterPosition, position.id).status == "dropped"
      assert Repo.get!(FantasyTeam, team_a.id).waiver_position == 3
      assert Repo.get!(FantasyTeam, team_b.id).waiver_position == 1
      assert Repo.get!(FantasyTeam, team_c.id).waiver_position == 2
      assert Repo.aggregate(RosterPosition, :count, :id) == 2
    end

    test "processes a successful waiver with only a drop", %{conn: conn} do
      league = insert(:fantasy_league)
      team_a = insert(:fantasy_team, waiver_position: 2, fantasy_league: league)
      team_b = insert(:fantasy_team, waiver_position: 1, fantasy_league: league)
      team_c = insert(:fantasy_team, waiver_position: 3, fantasy_league: league)
      player_a = insert(:fantasy_player)

      position =
        insert(
          :roster_position,
          fantasy_team: team_a,
          fantasy_player: player_a
        )

      waiver =
        insert(
          :waiver,
          fantasy_team: team_a,
          drop_fantasy_player: player_a,
          add_fantasy_player: nil
        )

      params = %{status: "successful"}

      conn = patch(conn, ~p"/waiver_admin/#{waiver.id}", waiver: params)

      assert redirected_to(conn) ==
               ~p"/fantasy_leagues/#{team_a.fantasy_league_id}/waivers"

      assert Repo.get!(Waiver, waiver.id).status == "successful"
      assert Repo.get!(RosterPosition, position.id).status == "dropped"
      assert Repo.get!(FantasyTeam, team_a.id).waiver_position == 2
      assert Repo.get!(FantasyTeam, team_b.id).waiver_position == 1
      assert Repo.get!(FantasyTeam, team_c.id).waiver_position == 3
      assert Repo.aggregate(RosterPosition, :count, :id) == 1
    end

    test "processes a successful waiver with only an add", %{conn: conn} do
      league = insert(:fantasy_league)
      team_a = insert(:fantasy_team, waiver_position: 2, fantasy_league: league)
      team_b = insert(:fantasy_team, waiver_position: 1, fantasy_league: league)
      team_c = insert(:fantasy_team, waiver_position: 3, fantasy_league: league)
      player_a = insert(:fantasy_player)
      player_b = insert(:fantasy_player)

      insert(
        :roster_position,
        fantasy_team: team_a,
        fantasy_player: player_a
      )

      waiver =
        insert(
          :waiver,
          fantasy_team: team_a,
          drop_fantasy_player: nil,
          add_fantasy_player: player_b
        )

      params = %{status: "successful"}

      conn = patch(conn, ~p"/waiver_admin/#{waiver.id}", waiver: params)

      assert redirected_to(conn) ==
               ~p"/fantasy_leagues/#{team_a.fantasy_league_id}/waivers"

      assert Repo.get!(Waiver, waiver.id).status == "successful"
      assert Repo.get!(FantasyTeam, team_a.id).waiver_position == 3
      assert Repo.get!(FantasyTeam, team_b.id).waiver_position == 1
      assert Repo.get!(FantasyTeam, team_c.id).waiver_position == 2
      assert Repo.aggregate(RosterPosition, :count, :id) == 2
    end

    test "processes an invalid waiver", %{conn: conn} do
      league = insert(:fantasy_league)
      team_a = insert(:fantasy_team, waiver_position: 2, fantasy_league: league)
      team_b = insert(:fantasy_team, waiver_position: 1, fantasy_league: league)
      team_c = insert(:fantasy_team, waiver_position: 3, fantasy_league: league)
      player_a = insert(:fantasy_player)
      player_b = insert(:fantasy_player)

      insert(
        :roster_position,
        fantasy_team: team_a,
        fantasy_player: player_a
      )

      waiver =
        insert(
          :waiver,
          fantasy_team: team_a,
          drop_fantasy_player: player_a,
          add_fantasy_player: player_b
        )

      params = %{status: "invalid"}

      conn = patch(conn, ~p"/waiver_admin/#{waiver.id}", waiver: params)

      assert redirected_to(conn) ==
               ~p"/fantasy_leagues/#{team_a.fantasy_league_id}/waivers"

      assert Repo.get!(Waiver, waiver.id).status == "invalid"
      assert Repo.get!(FantasyTeam, team_a.id).waiver_position == 2
      assert Repo.get!(FantasyTeam, team_b.id).waiver_position == 1
      assert Repo.get!(FantasyTeam, team_c.id).waiver_position == 3
      assert Repo.aggregate(RosterPosition, :count, :id) == 1
    end

    test "processes unsuccessful waiver", %{conn: conn} do
      league = insert(:fantasy_league)
      team_a = insert(:fantasy_team, waiver_position: 2, fantasy_league: league)
      team_b = insert(:fantasy_team, waiver_position: 1, fantasy_league: league)
      team_c = insert(:fantasy_team, waiver_position: 3, fantasy_league: league)
      player_a = insert(:fantasy_player)
      player_b = insert(:fantasy_player)

      insert(
        :roster_position,
        fantasy_team: team_a,
        fantasy_player: player_a
      )

      waiver =
        insert(
          :waiver,
          fantasy_team: team_a,
          drop_fantasy_player: player_a,
          add_fantasy_player: player_b
        )

      params = %{status: "unsuccessful"}

      conn = patch(conn, ~p"/waiver_admin/#{waiver.id}", waiver: params)

      assert redirected_to(conn) ==
               ~p"/fantasy_leagues/#{team_a.fantasy_league_id}/waivers"

      assert Repo.get!(Waiver, waiver.id).status == "unsuccessful"
      assert Repo.get!(FantasyTeam, team_a.id).waiver_position == 2
      assert Repo.get!(FantasyTeam, team_b.id).waiver_position == 1
      assert Repo.get!(FantasyTeam, team_c.id).waiver_position == 3
      assert Repo.aggregate(RosterPosition, :count, :id) == 1
    end
  end

  describe "waiver_admin as a user" do
    setup :register_and_log_in_user

    test "edit redirects to root if user is not admin", %{conn: conn} do
      waiver = insert(:waiver)

      conn = get(conn, ~p"/waiver_admin/#{waiver.id}/edit")

      assert html_response(conn, 302) =~ ~r/redirected/
    end

    test "update redirects to root if user is not admin", %{conn: conn} do
      waiver = insert(:waiver)
      params = %{status: "higher priority claim submitted"}

      conn = patch(conn, ~p"/waiver_admin/#{waiver.id}", waiver: params)

      assert html_response(conn, 302) =~ ~r/redirected/
    end
  end
end
