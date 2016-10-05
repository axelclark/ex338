defmodule Ex338.WaiverControllerTest do
  use Ex338.ConnCase
  alias Ex338.{Waiver, User, RosterPosition, FantasyTeam}

  setup %{conn: conn} do
    user = %User{name: "test", email: "test@example.com", id: 1}
    {:ok, conn: assign(conn, :current_user, user), user: user}
  end

  describe "index/2" do
    test "lists all waivers in a league", %{conn: conn} do
      league = insert(:fantasy_league)
      other_league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      player = insert(:fantasy_player)
      other_team = insert(:fantasy_team, team_name: "Another Team",
                                         fantasy_league: other_league)
      insert(:waiver, fantasy_team: team, add_fantasy_player: player,
                      status: "successful")
      insert(:waiver, fantasy_team: other_team, add_fantasy_player: player,
                      status: "successful")

      conn = get conn, fantasy_league_waiver_path(conn, :index, league.id)

      assert html_response(conn, 200) =~ ~r/Waivers/
      assert String.contains?(conn.resp_body, team.team_name)
      assert String.contains?(conn.resp_body, player.player_name)
      refute String.contains?(conn.resp_body, other_team.team_name)
    end
  end

  describe "new/2" do
    test "renders a form to submit a waiver", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      insert(:owner, fantasy_team: team, user: conn.assigns.current_user)
      player_a = insert(:fantasy_player)
      _player_b = insert(:fantasy_player)
      insert(:roster_position, fantasy_player: player_a, fantasy_team: team)

      conn = get conn, fantasy_team_waiver_path(conn, :new, team.id)

      assert html_response(conn, 200) =~ ~r/Submit New Waiver/
      assert String.contains?(conn.resp_body, team.team_name)
    end

    test "redirects to root if user is not owner", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      player_a = insert(:fantasy_player)
      _player_b = insert(:fantasy_player)
      insert(:roster_position, fantasy_player: player_a, fantasy_team: team)

      conn = get conn, fantasy_team_waiver_path(conn, :new, team.id)

      assert html_response(conn, 302) =~ ~r/redirected/
    end
  end

  describe "create/2" do
    test "creates a waiver and redirects", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      insert(:owner, fantasy_team: team, user: conn.assigns.current_user)
      player_a = insert(:fantasy_player)
      player_b = insert(:fantasy_player)
      insert(:roster_position, fantasy_player: player_a, fantasy_team: team)
      attrs = %{drop_fantasy_player_id: player_a.id,
                add_fantasy_player_id: player_b.id}

      conn = post conn, fantasy_team_waiver_path(conn, :create, team.id,
                                                 waiver: attrs)
      result = Repo.get_by!(Waiver, attrs)

      assert result.fantasy_team_id == team.id
      assert result.status == "pending"
      assert redirected_to(conn) == fantasy_team_path(conn, :show, team.id)
    end

    test "does not update and renders errors when invalid", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      insert(:owner, fantasy_team: team, user: conn.assigns.current_user)
      player_a = insert(:fantasy_player)
      _player_b = insert(:fantasy_player)
      insert(:roster_position, fantasy_player: player_a, fantasy_team: team)
      invalid_attrs = %{drop_fantasy_player: "", add_fantasy_player_id: ""}

      conn = post conn, fantasy_team_waiver_path(conn, :create, team.id,
                                                 waiver: invalid_attrs)

      assert html_response(conn, 200) =~ "Please check the errors below."
    end

    test "redirects to root if user is not owner", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      player_a = insert(:fantasy_player)
      player_b = insert(:fantasy_player)
      insert(:roster_position, fantasy_player: player_a, fantasy_team: team)
      attrs = %{drop_fantasy_player_id: player_a.id,
                add_fantasy_player_id: player_b.id}

      conn = post conn, fantasy_team_waiver_path(conn, :create, team.id,
                                                 waiver: attrs)

      assert html_response(conn, 302) =~ ~r/redirected/
    end
  end

  describe "edit/2" do
    test "renders a form for admin to process a waiver", %{conn: conn} do
      conn = put_in(conn.assigns.current_user.admin, true)
      team = insert(:fantasy_team, waiver_position: 1)
      player_a = insert(:fantasy_player)
      player_b = insert(:fantasy_player)
      waiver = insert(:waiver, fantasy_team: team,
                               drop_fantasy_player: player_a,
                               add_fantasy_player:  player_b)

      conn = get conn, waiver_path(conn, :edit, waiver.id)

      assert html_response(conn, 200) =~ ~r/Process Waiver/
      assert String.contains?(conn.resp_body, team.team_name)
      assert String.contains?(conn.resp_body, "1")
      assert String.contains?(conn.resp_body, player_a.player_name)
      assert String.contains?(conn.resp_body, player_b.player_name)
    end

    test "redirects to root if user is not admin", %{conn: conn} do
      waiver = insert(:waiver)

      conn = get conn, waiver_path(conn, :edit, waiver.id)

      assert html_response(conn, 302) =~ ~r/redirected/
    end
  end

  describe "update/2" do
    test "processes a successful waiver", %{conn: conn} do
      conn = put_in(conn.assigns.current_user.admin, true)
      league = insert(:fantasy_league)
      team_a = insert(:fantasy_team, waiver_position: 2, fantasy_league: league)
      team_b = insert(:fantasy_team, waiver_position: 1, fantasy_league: league)
      team_c = insert(:fantasy_team, waiver_position: 3, fantasy_league: league)
      player_a = insert(:fantasy_player)
      player_b = insert(:fantasy_player)
      position = insert(:roster_position, fantasy_team: team_a,
                                          fantasy_player: player_a)
      waiver = insert(:waiver, fantasy_team: team_a,
                               drop_fantasy_player: player_a,
                               add_fantasy_player:  player_b)
      params = %{status: "successful"}

      conn = patch conn, waiver_path(conn, :update, waiver.id, waiver: params)

      assert redirected_to(conn) == fantasy_league_waiver_path(conn, :index,
                                      team_a.fantasy_league_id)
      assert Repo.get!(Waiver, waiver.id).status == "successful"
      assert Repo.get!(RosterPosition, position.id).status == "dropped"
      assert Repo.get!(FantasyTeam, team_a.id).waiver_position == 3
      assert Repo.get!(FantasyTeam, team_b.id).waiver_position == 1
      assert Repo.get!(FantasyTeam, team_c.id).waiver_position == 2
      assert Repo.aggregate(RosterPosition, :count, :id) == 2
    end

    test "processes a successful waiver with only a drop", %{conn: conn} do
      conn = put_in(conn.assigns.current_user.admin, true)
      league = insert(:fantasy_league)
      team_a = insert(:fantasy_team, waiver_position: 2, fantasy_league: league)
      team_b = insert(:fantasy_team, waiver_position: 1, fantasy_league: league)
      team_c = insert(:fantasy_team, waiver_position: 3, fantasy_league: league)
      player_a = insert(:fantasy_player)
      position = insert(:roster_position, fantasy_team: team_a,
                                          fantasy_player: player_a)
      waiver = insert(:waiver, fantasy_team: team_a,
                               drop_fantasy_player: player_a,
                               add_fantasy_player:  nil)
      params = %{status: "successful"}

      conn = patch conn, waiver_path(conn, :update, waiver.id, waiver: params)

      assert redirected_to(conn) == fantasy_league_waiver_path(conn, :index,
                                      team_a.fantasy_league_id)
      assert Repo.get!(Waiver, waiver.id).status == "successful"
      assert Repo.get!(RosterPosition, position.id).status == "dropped"
      assert Repo.get!(FantasyTeam, team_a.id).waiver_position == 2
      assert Repo.get!(FantasyTeam, team_b.id).waiver_position == 1
      assert Repo.get!(FantasyTeam, team_c.id).waiver_position == 3
      assert Repo.aggregate(RosterPosition, :count, :id) == 1
    end

    test "processes a successful waiver with only an add", %{conn: conn} do
      conn = put_in(conn.assigns.current_user.admin, true)
      league = insert(:fantasy_league)
      team_a = insert(:fantasy_team, waiver_position: 2, fantasy_league: league)
      team_b = insert(:fantasy_team, waiver_position: 1, fantasy_league: league)
      team_c = insert(:fantasy_team, waiver_position: 3, fantasy_league: league)
      player_a = insert(:fantasy_player)
      player_b = insert(:fantasy_player)
      insert(:roster_position, fantasy_team: team_a,
                               fantasy_player: player_a)
      waiver = insert(:waiver, fantasy_team: team_a,
                               drop_fantasy_player: nil,
                               add_fantasy_player:  player_b)

      params = %{status: "successful"}

      conn = patch conn, waiver_path(conn, :update, waiver.id, waiver: params)

      assert redirected_to(conn) == fantasy_league_waiver_path(conn, :index,
                                      team_a.fantasy_league_id)
      assert Repo.get!(Waiver, waiver.id).status == "successful"
      assert Repo.get!(FantasyTeam, team_a.id).waiver_position == 3
      assert Repo.get!(FantasyTeam, team_b.id).waiver_position == 1
      assert Repo.get!(FantasyTeam, team_c.id).waiver_position == 2
      assert Repo.aggregate(RosterPosition, :count, :id) == 2
    end

    test "processes an invalid waiver", %{conn: conn} do
      conn = put_in(conn.assigns.current_user.admin, true)
      league = insert(:fantasy_league)
      team_a = insert(:fantasy_team, waiver_position: 2, fantasy_league: league)
      team_b = insert(:fantasy_team, waiver_position: 1, fantasy_league: league)
      team_c = insert(:fantasy_team, waiver_position: 3, fantasy_league: league)
      player_a = insert(:fantasy_player)
      player_b = insert(:fantasy_player)
      insert(:roster_position, fantasy_team: team_a,
                                          fantasy_player: player_a)
      waiver = insert(:waiver, fantasy_team: team_a,
                               drop_fantasy_player: player_a,
                               add_fantasy_player:  player_b)
      params = %{status: "invalid"}

      conn = patch conn, waiver_path(conn, :update, waiver.id, waiver: params)

      assert redirected_to(conn) == fantasy_league_waiver_path(conn, :index,
                                      team_a.fantasy_league_id)
      assert Repo.get!(Waiver, waiver.id).status == "invalid"
      assert Repo.get!(FantasyTeam, team_a.id).waiver_position == 2
      assert Repo.get!(FantasyTeam, team_b.id).waiver_position == 1
      assert Repo.get!(FantasyTeam, team_c.id).waiver_position == 3
      assert Repo.aggregate(RosterPosition, :count, :id) == 1
    end

    test "processes unsuccessful waiver", %{conn: conn} do
      conn = put_in(conn.assigns.current_user.admin, true)
      league = insert(:fantasy_league)
      team_a = insert(:fantasy_team, waiver_position: 2, fantasy_league: league)
      team_b = insert(:fantasy_team, waiver_position: 1, fantasy_league: league)
      team_c = insert(:fantasy_team, waiver_position: 3, fantasy_league: league)
      player_a = insert(:fantasy_player)
      player_b = insert(:fantasy_player)
      insert(:roster_position, fantasy_team: team_a,
                                          fantasy_player: player_a)
      waiver = insert(:waiver, fantasy_team: team_a,
                               drop_fantasy_player: player_a,
                               add_fantasy_player:  player_b)
      params = %{status: "unsuccessful"}

      conn = patch conn, waiver_path(conn, :update, waiver.id, waiver: params)

      assert redirected_to(conn) == fantasy_league_waiver_path(conn, :index,
                                      team_a.fantasy_league_id)
      assert Repo.get!(Waiver, waiver.id).status == "unsuccessful"
      assert Repo.get!(FantasyTeam, team_a.id).waiver_position == 2
      assert Repo.get!(FantasyTeam, team_b.id).waiver_position == 1
      assert Repo.get!(FantasyTeam, team_c.id).waiver_position == 3
      assert Repo.aggregate(RosterPosition, :count, :id) == 1
    end

    test "redirects to root if user is not admin", %{conn: conn} do
      waiver = insert(:waiver)
      params = %{status: "higher priority claim submitted"}

      conn = patch conn, waiver_path(conn, :update, waiver.id, waiver: params)

      assert html_response(conn, 302) =~ ~r/redirected/
    end
  end
end
