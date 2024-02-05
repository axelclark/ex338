defmodule Ex338.CalendarAssistantTest do
  use Ex338.DataCase, async: true

  alias Ex338.CalendarAssistant

  describe "days_from_now/1" do
    test "returns a date a specified number of days from now" do
      now = DateTime.utc_now()
      yesterday = CalendarAssistant.days_from_now(-1)
      tomorrow = CalendarAssistant.days_from_now(1)

      assert DateTime.after?(now, yesterday)
      assert DateTime.before?(now, tomorrow)
    end
  end

  describe "mins_from_now/1" do
    test "returns a date a specified number of mins from now" do
      now = DateTime.utc_now()
      before = CalendarAssistant.mins_from_now(-1)
      later = CalendarAssistant.mins_from_now(1)

      assert DateTime.after?(now, before)
      assert DateTime.before?(now, later)
    end
  end
end
