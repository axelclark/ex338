defmodule Ex338.CalendarAssistant do
  @moduledoc """
  Functions to add days to a date
  """

  def days_from_now(days) do
    days = 86_400 * days
    now = DateTime.truncate(DateTime.utc_now(), :second)

    Calendar.DateTime.add!(now, days)
  end

  def mins_from_now(mins) do
    mins = 60 * mins
    now = DateTime.truncate(DateTime.utc_now(), :second)

    Calendar.DateTime.add!(now, mins)
  end
end
