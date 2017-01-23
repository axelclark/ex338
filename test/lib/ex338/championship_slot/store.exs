defmodule Ex338.ChampionshipSlot.StoreTest do
  use Ex338.ModelCase
  alias Ex338.{ChampionshipSlot.Store, ChampionshipSlot}

  describe "create_slots_for_league/2" do
    test "admin creates roster slots for a championship" do
      league = insert(:fantasy_league)
      sport = insert(:sports_league)
      other_sport = insert(:sports_league)
      championship =
        insert(:championship, category: "event", sports_league: sport)
      _other_championship =
        insert(:championship, category: "event", sports_league: other_sport)
      player_a = insert(:fantasy_player, sports_league: sport)
      player_b = insert(:fantasy_player, sports_league: sport)
      player_c = insert(:fantasy_player, sports_league: sport)
      other_player = insert(:fantasy_player, sports_league: other_sport)
      team = insert(:fantasy_team, fantasy_league: league)
      primary = insert(:roster_position, fantasy_player: player_a,
        fantasy_team: team, status: "active", position: "CBB")
      flex = insert(:roster_position, fantasy_player: player_b,
        fantasy_team: team, status: "active", position: "Flex1")
      insert(:roster_position, fantasy_player: player_c, fantasy_team: team,
        status: "traded")
      insert(:roster_position, fantasy_player: other_player, fantasy_team: team,
        status: "active")

      Store.create_slots_for_league(championship.id, league.id)
      results = Repo.all(ChampionshipSlot)
      IO.inspect results

      assert Enum.map(results, &(&1.roster_position_id)) ==
        [primary.id, flex.id]
    end
  end
end
