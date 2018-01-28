defmodule Ex338.CalendarAssistantTest do
  use Ex338.DataCase
  alias Ex338.{CalendarAssistant}

  describe "days_from_now/1" do
    test "returns a date a specified number of days from now" do
      now = DateTime.utc_now()
      yesterday = CalendarAssistant.days_from_now(-1)
      tomorrow  = CalendarAssistant.days_from_now(1)

      assert DateTime.compare(now, yesterday) == :gt
      assert DateTime.compare(now, tomorrow) == :lt
    end
  end
end
