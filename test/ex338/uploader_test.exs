defmodule Ex338.UploaderTest do
  use Ex338.DataCase

  alias Ex338.{FantasyTeam, Repo, Uploader}

  describe "insert_from_csv/2" do
    test "inserts data from a csv into a fantasy team table" do
      file_path = "test/fixtures/fantasy_team_csv_table.csv"
      table = "FantasyTeam"
      insert(:fantasy_league, id: 1)
      insert(:fantasy_league, id: 2)

      {:ok, _results} = Uploader.insert_from_csv(file_path, table)

      teams = Repo.all(FantasyTeam)
      assert Enum.map(teams, & &1.team_name) == ["A", "B", "C"]
      assert Enum.map(teams, & &1.fantasy_league_id) == [1, 1, 2]
    end

    test "returns error if changes are invalid" do
      file_path = "test/fixtures/fantasy_team_csv_table.csv"
      table = "FantasyTeam"

      {:error, _, changeset, _} = Uploader.insert_from_csv(file_path, table)

      refute changeset.valid?
    end
  end

  describe "build_multis_from_rows/2" do
    test "builds a multi with rows from a CSV file" do
      table = "FantasyTeam"

      rows = [
        %{
          "commish_notes" => "",
          "dues_paid" => "0",
          "fantasy_league_id" => "1",
          "projected_id" => "68",
          "team_name" => "A",
          "waiver_position" => "1",
          "winnings_adj" => "0",
          "winnings_received" => "0"
        },
        %{
          "commish_notes" => "My team",
          "dues_paid" => "0",
          "fantasy_league_id" => "1",
          "projected_id" => "69",
          "team_name" => "B",
          "waiver_position" => "1",
          "winnings_adj" => "0",
          "winnings_received" => "0"
        },
        %{
          "commish_notes" => "Your team",
          "dues_paid" => "0",
          "fantasy_league_id" => "2",
          "projected_id" => "70",
          "team_name" => "C",
          "waiver_position" => "1",
          "winnings_adj" => "0",
          "winnings_received" => "0"
        }
      ]

      multi = Uploader.build_inserts_from_rows(rows, table)

      assert [
               {{Ex338.FantasyTeam, 1}, {:insert, changeset1, []}},
               {{Ex338.FantasyTeam, 2}, {:insert, changeset2, []}},
               {{Ex338.FantasyTeam, 3}, {:insert, changeset3, []}}
             ] = Ecto.Multi.to_list(multi)

      assert changeset1.valid?
      assert changeset2.valid?
      assert changeset3.valid?
    end

    test "error if changest is invalid" do
      table = "FantasyTeam"

      rows = [
        %{
          "fantasy_league_id" => "1"
        }
      ]

      multi = Uploader.build_inserts_from_rows(rows, table)

      assert [
               {{Ex338.FantasyTeam, 1}, {:insert, changeset1, []}}
             ] = Ecto.Multi.to_list(multi)

      refute changeset1.valid?
    end
  end
end
