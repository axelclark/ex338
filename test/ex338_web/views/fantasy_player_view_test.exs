defmodule Ex338Web.FantasyPlayerViewTest do
  use Ex338Web.ConnCase, async: true

  alias Ex338Web.FantasyPlayerView

  describe "abbrev_from_players/1" do
    test "gets sport abbrev from players list" do
      players = [
        %{
          player_name: "A. Pavlyuchenkova",
          sports_league_id: 1,
          sports_league: %{
            abbrev: "WTn",
            league_name: "Women's Tennis"
          }
        },
        %{
          player_name: "A. Radwanska",
          sports_league_id: 1,
          sports_league: %{
            abbrev: "WTn",
            league_name: "Women's Tennis"
          }
        },
        %{
          player_name: "A. Smith",
          sports_league_id: 1,
          sports_league: %{
            abbrev: "WTn",
            league_name: "Women's Tennis"
          }
        }
      ]

      result = FantasyPlayerView.abbrev_from_players(players)

      assert result == "WTn"
    end
  end

  describe "format_sport_select/1" do
    test "transforms list of players to select options for sport" do
      players = %{
        "Women's Tennis" => [
          %{
            player_name: "A. Pavlyuchenkova",
            sports_league_id: 1,
            sports_league: %{
              abbrev: "WTn",
              league_name: "Women's Tennis"
            }
          },
          %{
            player_name: "A. Radwanska",
            sports_league_id: 1,
            sports_league: %{
              abbrev: "WTn",
              league_name: "Women's Tennis"
            }
          }
        ],
        "Champions League" => [
          %{
            player_name: "Arsenal",
            sports_league_id: 2,
            sports_league: %{
              abbrev: "CL",
              league_name: "Champions League"
            }
          },
          %{
            player_name: "Atletico Madrid",
            sports_league_id: 2,
            sports_league: %{
              abbrev: "CL",
              league_name: "Champions League"
            }
          }
        ]
      }

      result = FantasyPlayerView.format_sports_for_select(players)

      assert result == [
               [key: "Champions League", value: "CL"],
               [key: "Women's Tennis", value: "WTn"]
             ]
    end
  end

  describe "get_result/1" do
    test "gets championship_result from player" do
      player = %{championship_results: [%{id: 1}]}

      result = FantasyPlayerView.get_result(player)

      assert result.id == 1
    end

    test "returns nil with no results" do
      player = %{championship_results: []}

      result = FantasyPlayerView.get_result(player)

      assert result == nil
    end
  end

  describe "get_team/1" do
    test "gets team from player" do
      player = %{roster_positions: [%{fantasy_team: %{id: 1}}]}

      result = FantasyPlayerView.get_team(player)

      assert result.id == 1
    end

    test "returns nil with no results" do
      player = %{roster_positions: []}

      result = FantasyPlayerView.get_team(player)

      assert result == nil
    end
  end
end
