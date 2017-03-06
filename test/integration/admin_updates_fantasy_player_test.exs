defmodule Ex338.AdminUpdatesFantasyPlayerTest do
  use Ex338.AcceptanceCase, async: true

  @tag integration: true
  test "admin updatest fantasy team", %{session: session} do
    insert_admin(%{email: "test@example.com", password: "secret"})
    sports_league = insert(:sports_league, league_name: "NFL")
    insert(:fantasy_player, player_name: "St Louis Rams",
                            sports_league: sports_league)

    session
    |> visit("/admin")
    |> fill_in(Query.text_field("Email"), with: "test@example.com")
    |> fill_in(Query.text_field("Password"), with: "secret")
    |> click(Query.button("Sign In"))
    |> click(Query.link("FantasyPlayer"))
    |> click(Query.link("Edit"))
    |> find(Query.css("#new_fantasy_player"))
    |> fill_in(Query.text_field("Player Name"), with: "LA Rams")
    |> click(Query.button("Update Fantasyplayer"))

    notice =
      session
      |> find(Query.css(".alert-success"))
      |> Element.text

    assert notice =~ ~R/Fantasy Player was successfully updated./
  end
end
