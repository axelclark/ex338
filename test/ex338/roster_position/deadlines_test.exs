defmodule Ex338.RosterPosition.DeadlinesTest do
  use Ex338.DataCase

  alias Ex338.{CalendarAssistant, RosterPosition.Deadlines}

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
                    %{
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
                    %{
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
                    %{
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
                    %{
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
      %{roster_positions: [a, b]} = team_a

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
                  %{
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
                  %{
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

      assert a.season_ended? == false
      assert a.waivers_closed? == false
      assert a.trades_closed? == false
      assert b.season_ended? == true
      assert b.waivers_closed? == true
      assert b.trades_closed? == true
      assert c.season_ended? == false
      assert c.waivers_closed? == false
      assert c.trades_closed? == false
    end
  end
end
