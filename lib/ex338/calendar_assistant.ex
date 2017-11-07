defmodule Ex338.CalendarAssistant do
  @moduledoc """
  Functions to add days to a date
  """

  def datetime_add_days(datetime, days) do
    days = (86_400 * days)

    Calendar.DateTime.add!(datetime, days)
  end

  def days_from_now(days) do
    days = (86_400 * days)
    now = DateTime.utc_now

    Calendar.DateTime.add!(now, days)
  end
end
