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

  describe "datetime_add_days/2" do
    test "returns a date a specified number of days from a given date" do
      datetime = DateTime.from_naive!(~N[2016-05-24 13:26:08.003], "Etc/UTC")
      five_days_later =
        DateTime.from_naive!(~N[2016-05-29 13:26:08.003], "Etc/UTC")

      assert CalendarAssistant.datetime_add_days(datetime, 5) == five_days_later
    end
  end
end
