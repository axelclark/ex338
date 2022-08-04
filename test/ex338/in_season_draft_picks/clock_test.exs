defmodule Ex338.InSeasonInSeasonDraftPicks.ClockTest do
  use Ex338.DataCase, async: true

  alias Ex338.{
    CalendarAssistant,
    Championships.Championship,
    InSeasonDraftPicks.Clock,
    InSeasonDraftPicks.InSeasonDraftPick
  }

  describe "update_in_season_draft_picks/2" do
    test "1st pick not available before draft" do
      championship = %Championship{
        max_draft_mins: 5,
        draft_starts_at: CalendarAssistant.mins_from_now(5)
      }

      in_season_draft_pick = [
        %InSeasonDraftPick{
          position: 1,
          drafted_at: nil,
          drafted_player_id: nil
        }
      ]

      [a] = Clock.update_in_season_draft_picks(in_season_draft_pick, championship)

      assert a.available_to_pick? == false
      assert a.pick_due_at == CalendarAssistant.mins_from_now(10)
      assert a.over_time? == false
    end

    test "1st pick available after draft starts" do
      championship = %Championship{
        max_draft_mins: 5,
        draft_starts_at: CalendarAssistant.mins_from_now(-1)
      }

      in_season_draft_pick = [
        %InSeasonDraftPick{
          position: 1,
          drafted_at: nil,
          drafted_player_id: nil
        }
      ]

      [a] = Clock.update_in_season_draft_picks(in_season_draft_pick, championship)

      assert a.available_to_pick? == true
      assert a.pick_due_at == CalendarAssistant.mins_from_now(4)
      assert a.over_time? == false
    end

    test "returns list of in season draft picks with data" do
      championship = %Championship{
        max_draft_mins: 5,
        draft_starts_at: CalendarAssistant.mins_from_now(-11)
      }

      in_season_draft_picks = [
        %InSeasonDraftPick{
          position: 1,
          drafted_at: CalendarAssistant.mins_from_now(-9),
          drafted_player_id: 1
        },
        %InSeasonDraftPick{
          position: 2,
          drafted_at: nil,
          drafted_player_id: nil
        },
        %InSeasonDraftPick{
          position: 3,
          drafted_at: nil,
          drafted_player_id: nil
        },
        %InSeasonDraftPick{
          position: 4,
          drafted_at: nil,
          drafted_player_id: nil
        }
      ]

      [a, b, c, d] = Clock.update_in_season_draft_picks(in_season_draft_picks, championship)

      assert a.available_to_pick? == false
      assert a.pick_due_at == CalendarAssistant.mins_from_now(-6)
      assert a.over_time? == false

      assert b.available_to_pick? == true
      assert b.pick_due_at == CalendarAssistant.mins_from_now(-4)
      assert b.over_time? == true

      assert c.available_to_pick? == true
      assert c.pick_due_at == CalendarAssistant.mins_from_now(1)
      assert c.over_time? == false

      assert d.available_to_pick? == false
      assert d.pick_due_at == CalendarAssistant.mins_from_now(6)
      assert d.over_time? == false
    end
  end
end
