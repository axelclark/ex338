defmodule Ex338.AdminCreatesDraftPickTest do
  use Ex338.AcceptanceCase, async: true

  test "admin creates draft pick", %{session: session} do
    insert(:fantasy_player, player_name: "LA Rams")
    fantasy_league = insert(:fantasy_league, year: 2016)
    insert(:fantasy_team, team_name: "Kintz", fantasy_league: fantasy_league)
     
    session
      |> visit("/admin")
      |> click_link("DraftPicks")
      |> click_link("New Draft Pick")
      |> find("#new_draftpick")
      |> fill_in("Draft Position", with: "1.01")
      |> select("draftpick_fantasy_league_id", option: "2016")
      |> select("draftpick_fantasy_team_id", option: "Kintz")
      |> select("draftpick_fantasy_player_id", option: "LA Rams")
      |> click_on("Create Draftpick")

    notice =
      session
      |> find(".alert-success")
      |> text

    assert notice =~ ~R/DraftPick was successfully created./
  end
end
