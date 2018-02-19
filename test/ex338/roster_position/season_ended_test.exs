defmodule Ex338.RosterPosition.SeasonEndedTest do
  use Ex338.DataCase

  alias Ex338.{RosterPosition.SeasonEnded, CalendarAssistant}

  describe "add_for_league/1" do
    test "add boolean whether season has ended" do
      teams = [
        %{
          team: "A",
          roster_positions: [
            %{
              pos: "A",
              fantasy_player: %{
                sports_league: %{
                  championships: [
                    %{championship_at: CalendarAssistant.days_from_now(9)}
                  ]
                }
              }
            },
            %{
              pos: "B",
              fantasy_player: %{
                sports_league: %{
                  championships: [
                    %{championship_at: CalendarAssistant.days_from_now(-9)}
                  ]
                }
              }
            }
          ]
        },
        %{
          team: "A",
          roster_positions: [
            %{
              pos: "A",
              fantasy_player: %{
                sports_league: %{
                  championships: [
                    %{championship_at: CalendarAssistant.days_from_now(9)}
                  ]
                }
              }
            },
            %{
              pos: "B",
              fantasy_player: %{
                sports_league: %{
                  championships: [
                    %{championship_at: CalendarAssistant.days_from_now(-9)}
                  ]
                }
              }
            }
          ]
        }
      ]

      [team_a, _team_b] = SeasonEnded.add_for_league(teams)
      %{roster_positions: [a, b]} = team_a

      assert a.season_ended? == false
      assert b.season_ended? == true
    end
  end

  describe "add_for_team/1" do
    test "add boolean whether season has ended" do
      team = %{
        roster_positions: [
          %{
            pos: "A",
            fantasy_player: %{
              sports_league: %{
                championships: [
                  %{championship_at: CalendarAssistant.days_from_now(9)}
                ]
              }
            }
          },
          %{
            pos: "B",
            fantasy_player: %{
              sports_league: %{
                championships: [
                  %{championship_at: CalendarAssistant.days_from_now(-9)}
                ]
              }
            }
          }
        ]
      }

      %{roster_positions: [a, b]} = SeasonEnded.add_for_team(team)

      assert a.season_ended? == false
      assert b.season_ended? == true
    end
  end
end
