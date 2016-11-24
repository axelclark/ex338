defmodule Ex338.CalendarAssistant do
  @moduledoc false

  def days_from_now(days) do
    days = (86_400 * days)
    now = Ecto.DateTime.utc
          |> Ecto.DateTime.to_erl
          |> Calendar.DateTime.from_erl!("UTC")

    now
    |> Calendar.DateTime.add!(days)
    |> Calendar.DateTime.to_erl
    |> Ecto.DateTime.from_erl
  end

  def datetime_add_days(datetime, days) do
    days = (86_400 * days)
    datetime = datetime
               |> Ecto.DateTime.to_erl
               |> Calendar.DateTime.from_erl!("UTC")

    datetime
    |> Calendar.DateTime.add!(days)
    |> Calendar.DateTime.to_erl
    |> Ecto.DateTime.from_erl
  end
end
