defmodule Ex338Web.WaiverHTMLTest do
  use Ex338Web.ConnCase, async: true

  alias Ex338.CalendarAssistant
  alias Ex338.Waivers.Waiver
  alias Ex338Web.WaiverHTML

  describe "sort_most_recent/1" do
    test "returns struct sorted by most recent first" do
      waivers = [
        %{
          fantasy_team: "a",
          process_at: CalendarAssistant.days_from_now(-5)
        },
        %{
          fantasy_team: "c",
          process_at: CalendarAssistant.days_from_now(-1)
        },
        %{
          fantasy_team: "b",
          process_at: CalendarAssistant.days_from_now(-3)
        }
      ]

      result = WaiverHTML.sort_most_recent(waivers)

      assert Enum.map(result, & &1.fantasy_team) == ["c", "b", "a"]
    end
  end

  describe "after_now?/1" do
    test "returns true if date is after now" do
      three_days_from_now = CalendarAssistant.days_from_now(3)

      result = WaiverHTML.after_now?(three_days_from_now)

      assert result == true
    end

    test "returns false if date is before now" do
      three_days_before_now = CalendarAssistant.days_from_now(-3)

      result = WaiverHTML.after_now?(three_days_before_now)

      assert result == false
    end
  end

  describe "display_name/1" do
    test "hides name if sport is hiding waiver claims" do
      player = %{player_name: "Michigan", sports_league: %{hide_waivers: true}}

      result = WaiverHTML.display_name(player)

      assert result == "*****"
    end

    test "displays name if sport is not hiding waiver claims" do
      player = %{player_name: "Michigan", sports_league: %{hide_waivers: false}}

      result = WaiverHTML.display_name(player)

      assert result == "Michigan"
    end
  end

  describe "within_two_hours_of_submittal?/1" do
    test "returns true if waiver submitted within two hours" do
      now = NaiveDateTime.utc_now()
      one_hour = 60 * 60 * -1
      one_hour_ago = NaiveDateTime.add(now, one_hour)
      waiver = %Waiver{inserted_at: one_hour_ago}

      result = WaiverHTML.within_two_hours_of_submittal?(waiver)

      assert result == true
    end

    test "returns false if waiver submitted more than two hours" do
      now = NaiveDateTime.utc_now()
      three_hours = 60 * 60 * 3 * -1
      three_hours_ago = NaiveDateTime.add(now, three_hours)
      waiver = %Waiver{inserted_at: three_hours_ago}

      result = WaiverHTML.within_two_hours_of_submittal?(waiver)

      assert result == false
    end
  end
end
