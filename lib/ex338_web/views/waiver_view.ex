defmodule Ex338Web.WaiverView do
  use Ex338Web, :view

  def after_now?(date_time) do
    case Ecto.DateTime.compare(date_time, Ecto.DateTime.utc) do
      :gt -> true
      :eq -> true
      :lt -> false
    end
  end

  def sort_most_recent(query) do
    Enum.sort(query, &(before_other_date?(&1.process_at, &2.process_at)))
  end

  defp before_other_date?(date1, date2) do
    case Ecto.DateTime.compare(date1, date2) do
      :gt -> true
      :eq -> true
      :lt -> false
    end
  end

  def display_name(%{sports_league: %{hide_waivers: true}}), do: "*****"

  def display_name(%{player_name: name} = _player), do: name
end
