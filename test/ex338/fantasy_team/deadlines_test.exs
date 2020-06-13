defmodule Ex338.FantasyTeam.DeadlinesTest do
  use Ex338.DataCase

  alias Ex338.{CalendarAssistant, Championships.Championship, FantasyTeam.Deadlines}

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
                    %Championship{
                      championship_at: CalendarAssistant.days_from_now(9),
                      waiver_deadline_at: CalendarAssistant.days_from_now(9),
                      trade_deadline_at: CalendarAssistant.days_from_now(9)
                    }
                  ]
                }
              }
            },
            %{
              pos: "B",
              fantasy_player: %{
                sports_league: %{
                  championships: [
                    %Championship{
                      championship_at: CalendarAssistant.days_from_now(-9),
                      waiver_deadline_at: CalendarAssistant.days_from_now(-9),
                      trade_deadline_at: CalendarAssistant.days_from_now(-9)
                    }
                  ]
                }
              }
            }
          ]
        },
        %{
          team: "B",
          roster_positions: [
            %{
              pos: "A",
              fantasy_player: %{
                sports_league: %{
                  championships: [
                    %Championship{
                      championship_at: CalendarAssistant.days_from_now(9),
                      waiver_deadline_at: CalendarAssistant.days_from_now(9),
                      trade_deadline_at: CalendarAssistant.days_from_now(9)
                    }
                  ]
                }
              }
            },
            %{
              pos: "B",
              fantasy_player: %{
                sports_league: %{
                  championships: [
                    %Championship{
                      championship_at: CalendarAssistant.days_from_now(-9),
                      waiver_deadline_at: CalendarAssistant.days_from_now(-9),
                      trade_deadline_at: CalendarAssistant.days_from_now(-9)
                    }
                  ]
                }
              }
            }
          ]
        }
      ]

      [team_a, _team_b] = Deadlines.add_for_league(teams)
      %{roster_positions: [ros_a, ros_b]} = team_a

      a = get_champ(ros_a)
      b = get_champ(ros_b)

      assert a.season_ended? == false
      assert a.waivers_closed? == false
      assert a.trades_closed? == false
      assert b.season_ended? == true
      assert b.waivers_closed? == true
      assert b.trades_closed? == true
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
                  %Championship{
                    championship_at: CalendarAssistant.days_from_now(9),
                    waiver_deadline_at: CalendarAssistant.days_from_now(9),
                    trade_deadline_at: CalendarAssistant.days_from_now(9)
                  }
                ]
              }
            }
          },
          %{
            pos: "B",
            fantasy_player: %{
              sports_league: %{
                championships: [
                  %Championship{
                    championship_at: CalendarAssistant.days_from_now(-9),
                    waiver_deadline_at: CalendarAssistant.days_from_now(-9),
                    trade_deadline_at: CalendarAssistant.days_from_now(-9)
                  }
                ]
              }
            }
          },
          %{
            pos: "C",
            fantasy_player: %{
              sports_league: %{
                championships: []
              }
            }
          }
        ]
      }

      %{roster_positions: [a, b, c]} = Deadlines.add_for_team(team)

      a = get_champ(a)
      b = get_champ(b)
      c = get_champ(c)

      assert a.season_ended? == false
      assert a.waivers_closed? == false
      assert a.trades_closed? == false
      assert b.season_ended? == true
      assert b.waivers_closed? == true
      assert b.trades_closed? == true
      assert c == nil
    end
  end

  defp get_champ(%{fantasy_player: %{sports_league: %{championships: [champ]}}}), do: champ
  defp get_champ(%{fantasy_player: %{sports_league: %{championships: []}}}), do: nil
end
