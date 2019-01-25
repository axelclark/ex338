defmodule Ex338Web.FantasyPlayerViewTest do
  use Ex338Web.ConnCase, async: true

  alias Ex338Web.FantasyPlayerView

  describe "format_sport_select/1" do
    test "transforms list of players to select options for sport" do
      players = %{
        "Women's Tennis" => [
          %{
            league_abbrev: "WTn",
            league_name: "Women's Tennis",
            player_name: "A. Pavlyuchenkova",
            points: nil,
            rank: nil,
            team_name: nil
          },
          %{
            league_abbrev: "WTn",
            league_name: "Women's Tennis",
            player_name: "A. Radwanska",
            points: nil,
            rank: nil,
            team_name: nil
          }
        ],
        "Champions League" => [
          %{
            league_abbrev: "CL",
            league_name: "Champions League",
            player_name: "Arsenal",
            points: nil,
            rank: nil,
            team_name: nil
          },
          %{
            league_abbrev: "CL",
            league_name: "Champions League",
            player_name: "Atletico Madrid",
            points: nil,
            rank: nil,
            team_name: nil
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

  describe "abbrev_from_players/1" do
    test "gets sport abbrev from players list" do
      players = [
        %{
          league_abbrev: "WTn",
          league_name: "Women's Tennis",
          player_name: "A. Pavlyuchenkova",
          points: nil,
          rank: nil,
          team_name: nil
        },
        %{
          league_abbrev: "WTn",
          league_name: "Women's Tennis",
          player_name: "A. Radwanska",
          points: nil,
          rank: nil,
          team_name: nil
        },
        %{
          league_abbrev: "WTn",
          league_name: "Women's Tennis",
          player_name: "A. Kerber",
          points: nil,
          rank: nil,
          team_name: nil
        }
      ]

      result = FantasyPlayerView.abbrev_from_players(players)

      assert result == "WTn"
    end
  end
end
