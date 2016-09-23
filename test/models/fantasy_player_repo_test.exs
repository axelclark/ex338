defmodule Ex338.FantasyPlayerRepoTest do
  use Ex338.ModelCase
  alias Ex338.FantasyPlayer
  describe "alphabetical_by_league/1" do
    test "returns players alphabetically sorted by league" do
      league_a = insert(:sports_league, league_name: "A")
      league_b = insert(:sports_league, league_name: "B")
      insert(:fantasy_player, player_name: "A", sports_league: league_b)
      insert(:fantasy_player, player_name: "B", sports_league: league_a)
      insert(:fantasy_player, player_name: "C", sports_league: league_a)

      query = FantasyPlayer |> FantasyPlayer.alphabetical_by_league
      query = from f in query, select: f.player_name

      assert Repo.all(query) == ~w(B C A)
    end
  end
  describe "names_and_ids/1" do
    test "selects names and ids" do
      player_a = insert(:fantasy_player, player_name: "A")
      player_b = insert(:fantasy_player, player_name: "B")

      query = FantasyPlayer |> FantasyPlayer.names_and_ids

      assert Repo.all(query) == [{"A", player_a.id}, {"B", player_b.id}]
    end
  end

  describe "available_players/1" do
    test "returns unowned players in a league for select option" do
      league_a = insert(:sports_league, abbrev: "A")
      league_b = insert(:sports_league, abbrev: "B")
      player_a = insert(:fantasy_player, sports_league: league_a)
      player_b = insert(:fantasy_player, sports_league: league_a)
      player_c = insert(:fantasy_player, sports_league: league_b)
      f_league_a = insert(:fantasy_league)
      f_league_b = insert(:fantasy_league)
      team_a = insert(:fantasy_team, fantasy_league: f_league_a)
      team_b = insert(:fantasy_team, fantasy_league: f_league_b)
      insert(:roster_position, fantasy_team: team_a, fantasy_player: player_a)
      insert(:roster_position, fantasy_team: team_b, fantasy_player: player_b)

      query = FantasyPlayer.available_players(f_league_a.id)

      assert Repo.all(query) == [
        %{player_name: player_b.player_name, league_abbrev: league_a.abbrev,
          id: player_b.id},
        %{player_name: player_c.player_name, league_abbrev: league_b.abbrev,
          id: player_c.id}
      ]
    end
  end
end
