defmodule Ex338.Waiver.BatchTest do
  use Ex338.DataCase, async: true

  alias Ex338.{Waiver, Waiver.Batch, FantasyTeam, CalendarAssistant}

  describe "group_and_sort/1" do
    test "groups waivers by fantasy league and add player" do
      waiver1 = CalendarAssistant.days_from_now(-6)
      waiver2 = CalendarAssistant.days_from_now(-5)
      waiver3 = CalendarAssistant.days_from_now(-4)

      waivers = [
        %Waiver{
          id: 1,
          add_fantasy_player_id: 1,
          process_at: waiver1,
          fantasy_team: %FantasyTeam{fantasy_league_id: 1, waiver_position: 2}
        },
        %Waiver{
          id: 2,
          add_fantasy_player_id: 1,
          process_at: waiver1,
          fantasy_team: %FantasyTeam{fantasy_league_id: 1, waiver_position: 1}
        },
        %Waiver{
          id: 3,
          add_fantasy_player_id: 1,
          process_at: waiver3,
          fantasy_team: %FantasyTeam{fantasy_league_id: 2, waiver_position: 5}
        },
        %Waiver{
          id: 4,
          add_fantasy_player_id: 2,
          process_at: waiver2,
          fantasy_team: %FantasyTeam{fantasy_league_id: 2, waiver_position: 7}
        }
      ]

      result = Batch.group_and_sort(waivers)

      assert result == [
               [
                 %Waiver{
                   id: 2,
                   add_fantasy_player_id: 1,
                   process_at: waiver1,
                   fantasy_team: %FantasyTeam{fantasy_league_id: 1, waiver_position: 1}
                 },
                 %Waiver{
                   id: 1,
                   add_fantasy_player_id: 1,
                   process_at: waiver1,
                   fantasy_team: %FantasyTeam{fantasy_league_id: 1, waiver_position: 2}
                 }
               ],
               [
                 %Waiver{
                   id: 4,
                   add_fantasy_player_id: 2,
                   process_at: waiver2,
                   fantasy_team: %FantasyTeam{fantasy_league_id: 2, waiver_position: 7}
                 }
               ],
               [
                 %Waiver{
                   id: 3,
                   add_fantasy_player_id: 1,
                   process_at: waiver3,
                   fantasy_team: %FantasyTeam{fantasy_league_id: 2, waiver_position: 5}
                 }
               ]
             ]
    end
  end

  describe "group_by_league/1" do
    test "groups waivers by fantasy league" do
      waivers = [
        %Waiver{id: 1, fantasy_team: %FantasyTeam{fantasy_league_id: 1}},
        %Waiver{id: 2, fantasy_team: %FantasyTeam{fantasy_league_id: 1}},
        %Waiver{id: 3, fantasy_team: %FantasyTeam{fantasy_league_id: 2}},
        %Waiver{id: 4, fantasy_team: %FantasyTeam{fantasy_league_id: 2}}
      ]

      [league1_waivers, league2_waivers] = Batch.group_by_league(waivers)

      assert Enum.map(league1_waivers, & &1.id) == [1, 2]
      assert Enum.map(league2_waivers, & &1.id) == [3, 4]
    end
  end

  describe "group_by_add_player/1" do
    test "groups waivers by player to add" do
      waivers = [
        %Waiver{id: 1, add_fantasy_player_id: 1},
        %Waiver{id: 2, add_fantasy_player_id: 1},
        %Waiver{id: 3, add_fantasy_player_id: 2},
        %Waiver{id: 4, add_fantasy_player_id: 2}
      ]

      [plyr1_waivers, plyr2_waivers] = Batch.group_by_add_player(waivers)

      assert Enum.map(plyr1_waivers, & &1.id) == [1, 2]
      assert Enum.map(plyr2_waivers, & &1.id) == [3, 4]
    end
  end

  describe "sort_by_waiver_positon/1" do
    test "sort waivers by waiver position" do
      waivers = [
        %Waiver{id: 1, fantasy_team: %FantasyTeam{waiver_position: 3}},
        %Waiver{id: 2, fantasy_team: %FantasyTeam{waiver_position: 2}},
        %Waiver{id: 3, fantasy_team: %FantasyTeam{waiver_position: 1}},
        %Waiver{id: 4, fantasy_team: %FantasyTeam{waiver_position: 4}}
      ]

      result = Batch.sort_by_waiver_position(waivers)

      assert Enum.map(result, & &1.id) == [3, 2, 1, 4]
    end
  end

  describe "sort_by_process_at/1" do
    test "sort waivers by earliest process at" do
      waivers = [
        [
          %Waiver{id: 1, process_at: CalendarAssistant.days_from_now(-3)},
          %Waiver{id: 2, process_at: CalendarAssistant.days_from_now(-3)}
        ],
        [
          %Waiver{id: 3, process_at: CalendarAssistant.days_from_now(-4)}
        ],
        [
          %Waiver{id: 4, process_at: CalendarAssistant.days_from_now(-5)}
        ]
      ]

      result = Batch.sort_by_process_at(waivers)

      assert Enum.map(result, &hd(&1).id) == [4, 3, 1]
    end
  end
end
