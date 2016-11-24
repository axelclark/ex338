defmodule Ex338.CalendarAssistantTest do
  use Ex338.ModelCase
  alias Ex338.{CalendarAssistant}

  describe "days_from_now/1" do
    test "returns a date a specified number of days from now" do
      now = Ecto.DateTime.utc
      yesterday = CalendarAssistant.days_from_now(-1)
      tomorrow  = CalendarAssistant.days_from_now(1)

      assert Ecto.DateTime.compare(now, yesterday) == :gt #gained time
      assert Ecto.DateTime.compare(now, tomorrow) == :lt  #lost time
    end
  end

  describe "datetime_add_days/2" do
    test "returns a date a specified number of days from a given date" do
      datetime = Ecto.DateTime.cast!(
        %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}
      )

      five_days_later = Ecto.DateTime.cast!(
        %{day: 22, hour: 14, min: 0, month: 4, sec: 0, year: 2010}
      )

      assert CalendarAssistant.datetime_add_days(datetime, 5) == five_days_later
    end
  end
end
