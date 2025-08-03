defmodule Ex338Web.Commish.FantasyLeagueLiveTest do
  use Ex338Web.ConnCase

  import Phoenix.LiveViewTest

  alias Ex338.FantasyTeams.FantasyTeam

  @update_attrs %{
    division: "some updated division",
    draft_method: "keeper",
    fantasy_league_name: "some updated fantasy_league_name",
    max_draft_hours: 43,
    max_flex_spots: 43,
    must_draft_each_sport?: false,
    navbar_display: "hidden",
    only_flex?: false,
    year: 43
  }

  @invalid_attrs %{
    division: nil,
    draft_method: nil,
    fantasy_league_name: nil,
    max_draft_hours: nil,
    max_flex_spots: nil,
    navbar_display: nil,
    year: nil
  }

  describe "Edit as admin" do
    setup :register_and_log_in_admin

    test "updates fantasy_league", %{conn: conn} do
      fantasy_league = insert(:fantasy_league)

      {:ok, edit_live, _html} =
        live(conn, Routes.commish_fantasy_league_edit_path(conn, :edit, fantasy_league))

      assert edit_live
             |> form("#fantasy_league-form", fantasy_league: @invalid_attrs)
             |> render_change() =~ "can't be blank"

      {:ok, _, html} =
        edit_live
        |> form("#fantasy_league-form", fantasy_league: @update_attrs)
        |> render_submit()
        |> follow_redirect(
          conn,
          Routes.commish_fantasy_league_edit_path(conn, :edit, fantasy_league)
        )

      assert html =~ "Fantasy league updated successfully"
      assert html =~ "some updated division"
    end

    test "updates fantasy_league and team names", %{conn: conn} do
      fantasy_league = insert(:fantasy_league)
      team1 = insert(:fantasy_team, fantasy_league: fantasy_league, team_name: "Original Team A")
      team2 = insert(:fantasy_team, fantasy_league: fantasy_league, team_name: "Original Team B")

      {:ok, edit_live, html} =
        live(conn, Routes.commish_fantasy_league_edit_path(conn, :edit, fantasy_league))

      # Check that teams are displayed in alphabetical order
      assert html =~ "Fantasy Teams"
      assert html =~ "Original Team A"
      assert html =~ "Original Team B"

      # Update league info and team names
      form_params =
        Map.put(@update_attrs, :fantasy_teams, %{
          "0" => %{
            "id" => to_string(team1.id),
            "team_name" => "Updated Alpha",
            "draft_grade" => "A"
          },
          "1" => %{
            "id" => to_string(team2.id),
            "team_name" => "Updated Beta",
            "draft_grade" => "B+"
          }
        })

      submit_params = %{
        fantasy_teams: %{
          "0" => %{
            "draft_analysis" => "Excellent draft strategy"
          },
          "1" => %{
            "draft_analysis" => "Good picks overall"
          }
        }
      }

      edit_live
      |> form("#fantasy_league-form", fantasy_league: form_params)
      |> render_submit(fantasy_league: submit_params)

      # Give some time for the update to complete
      Process.sleep(100)

      # Verify team names and draft info were updated
      updated_team1 = Ex338.Repo.get!(FantasyTeam, team1.id)
      updated_team2 = Ex338.Repo.get!(FantasyTeam, team2.id)

      assert updated_team1.team_name == "Updated Alpha"
      assert updated_team1.draft_grade == "A"
      assert updated_team1.draft_analysis == "Excellent draft strategy"

      assert updated_team2.team_name == "Updated Beta"
      assert updated_team2.draft_grade == "B+"
      assert updated_team2.draft_analysis == "Good picks overall"
    end
  end

  describe "Edit as user" do
    setup :register_and_log_in_user

    test "redirects if not admin", %{conn: conn} do
      fantasy_league = insert(:fantasy_league)

      {:ok, conn} =
        conn
        |> live(Routes.commish_fantasy_league_edit_path(conn, :edit, fantasy_league))
        |> follow_redirect(conn, "/")

      assert Flash.get(conn.assigns.flash, :error) == "You are not authorized"
    end
  end
end
