defmodule Ex338Web.TableUploadControllerTest do
  use Ex338Web.ConnCase

  alias Ex338.Accounts.User
  alias Ex338.FantasyTeams.FantasyTeam

  setup %{conn: conn} do
    user = %User{name: "test", email: "test@example.com", id: 1}
    {:ok, conn: assign(conn, :current_user, user), user: user}
  end

  describe "create/2" do
    test "loads csv data into a database table", %{conn: conn} do
      conn = put_in(conn.assigns.current_user.admin, true)
      insert(:fantasy_league, id: 1)
      insert(:fantasy_league, id: 2)

      file_path = "test/fixtures/fantasy_team_csv_table.csv"

      attrs = %{
        "table" => "FantasyTeams.FantasyTeam",
        "spreadsheet" => %Plug.Upload{path: file_path, filename: "fantasy_team_csv_table.csv"}
      }

      conn = post(conn, table_upload_path(conn, :create), table_upload: attrs)

      assert html_response(conn, 302) =~ ~r/redirected/
      teams = Repo.all(FantasyTeam)
      assert Enum.map(teams, & &1.team_name) == ["A", "B", "C"]
      assert Enum.map(teams, & &1.fantasy_league_id) == [1, 1, 2]
    end

    test "does not update and renders errors when invalid", %{conn: conn} do
      conn = put_in(conn.assigns.current_user.admin, true)

      file_path = "test/fixtures/fantasy_team_csv_table.csv"

      attrs = %{
        "table" => "FantasyTeams.FantasyTeam",
        "spreadsheet" => %Plug.Upload{path: file_path, filename: "fantasy_team_csv_table.csv"}
      }

      conn = post(conn, table_upload_path(conn, :create), table_upload: attrs)

      assert html_response(conn, 200) =~ "There was an error during the upload"
    end

    test "redirects to root if user is not admin", %{conn: conn} do
      attrs = %{}
      conn = post(conn, table_upload_path(conn, :create), table_upload: attrs)
      assert html_response(conn, 302) =~ ~r/redirected/
    end
  end

  describe "new/2" do
    test "renders a form to csv data", %{conn: conn} do
      conn = put_in(conn.assigns.current_user.admin, true)
      conn = get(conn, table_upload_path(conn, :new))
      assert html_response(conn, 200) =~ ~r/Upload Data from CSV Spreadsheet/
    end

    test "redirects to root if user is not admin", %{conn: conn} do
      conn = get(conn, table_upload_path(conn, :new))
      assert html_response(conn, 302) =~ ~r/redirected/
    end
  end
end
