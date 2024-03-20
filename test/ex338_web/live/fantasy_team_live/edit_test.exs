defmodule Ex338Web.FantasyTeamLive.EditTest do
  use Ex338Web.ConnCase

  import Phoenix.LiveViewTest

  alias Ex338.RosterPositions.RosterPosition

  @update_attrs %{
    team_name: "The Consortium"
  }
  @invalid_attrs %{team_name: nil}

  describe "Edit" do
    setup :register_and_log_in_user

    test "updates a team", %{conn: conn, user: user} do
      team = insert(:fantasy_team, team_name: "Brown")
      insert(:owner, fantasy_team: team, user: user)
      pos = insert(:roster_position, fantasy_team: team)

      {:ok, view, html} = live(conn, ~p"/fantasy_teams/#{team.id}/edit")

      assert html =~ "Update Team Info"
      assert html =~ team.team_name
      assert html =~ pos.fantasy_player.player_name

      assert view
             |> form("#fantasy-team-form", fantasy_team: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _view, html} =
        view
        |> form("#fantasy-team-form", fantasy_team: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/fantasy_teams/#{team}")

      assert html =~ "The Consortium"
    end

    test "updates a fantasy team's roster and redirects", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      insert(:owner, fantasy_team: team, user: conn.assigns.current_user)
      pos1 = insert(:roster_position, fantasy_team: team)
      pos2 = insert(:roster_position, fantasy_team: team)

      {:ok, view, _html} = live(conn, ~p"/fantasy_teams/#{team.id}/edit")

      invalid_attrs = %{
        "roster_positions" => %{
          "0" => %{"id" => pos1.id, "position" => "Flex1"},
          "1" => %{"id" => pos2.id, "position" => "Flex1"}
        }
      }

      view
      |> form("#fantasy-team-form", fantasy_team: invalid_attrs)
      |> render_submit() =~ "Already have a player in this position"

      valid_attrs = %{
        "roster_positions" => %{
          "0" => %{"id" => pos1.id, "position" => "Flex1"},
          "1" => %{"id" => pos2.id, "position" => "Flex2"}
        }
      }

      {:ok, _view, _html} =
        view
        |> form("#fantasy-team-form", fantasy_team: valid_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/fantasy_teams/#{team}")

      [p1, p2] = Repo.all(RosterPosition)

      assert p1.position == "Flex1"
      assert p2.position == "Flex2"
    end

    test "redirects to root if user is not owner", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)

      {:error, {:live_redirect, %{to: path}}} =
        live(conn, ~p"/fantasy_teams/#{team.id}/edit")

      assert path == ~p"/fantasy_teams/#{team.id}"
    end
  end
end
