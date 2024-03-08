defmodule Ex338Web.TableUploadControllerTest do
  use Ex338Web.ConnCase

  alias Ex338.FantasyTeams.FantasyTeam

  describe "create/2" do
    setup :register_and_log_in_admin

    test "loads csv data into a database table", %{conn: conn} do
      insert(:fantasy_league, id: 1)
      insert(:fantasy_league, id: 2)

      file_path = "test/fixtures/fantasy_team_csv_table.csv"

      attrs = %{
        "table" => "FantasyTeams.FantasyTeam",
        "spreadsheet" => %Plug.Upload{path: file_path, filename: "fantasy_team_csv_table.csv"}
      }

      conn = post(conn, ~p"/table_upload", table_upload: attrs)

      assert html_response(conn, 302) =~ ~r/redirected/
      teams = Repo.all(FantasyTeam)
      assert Enum.map(teams, & &1.team_name) == ["A", "B", "C"]
      assert Enum.map(teams, & &1.fantasy_league_id) == [1, 1, 2]
    end

    test "does not update and renders errors when invalid", %{conn: conn} do
      file_path = "test/fixtures/fantasy_team_csv_table.csv"

      attrs = %{
        "table" => "FantasyTeams.FantasyTeam",
        "spreadsheet" => %Plug.Upload{path: file_path, filename: "fantasy_team_csv_table.csv"}
      }

      conn = post(conn, ~p"/table_upload", table_upload: attrs)

      assert html_response(conn, 200) =~ "There was an error during the upload"
    end
  end

  describe "new/2" do
    setup :register_and_log_in_admin

    test "renders a form to csv data", %{conn: conn} do
      conn = get(conn, ~p"/table_upload/new")
      assert html_response(conn, 200) =~ ~r/Upload Data from CSV Spreadsheet/
    end
  end

  describe "/table_upload as user" do
    setup :register_and_log_in_user

    test "create redirects to root if user is not admin", %{conn: conn} do
      attrs = %{}
      conn = post(conn, ~p"/table_upload", table_upload: attrs)
      assert html_response(conn, 302) =~ ~r/redirected/
    end

    test "new redirects to root if user is not admin", %{conn: conn} do
      conn = get(conn, ~p"/table_upload/new")
      assert html_response(conn, 302) =~ ~r/redirected/
    end
  end
end
