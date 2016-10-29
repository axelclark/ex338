defmodule Ex338.WaiverView do
  use Ex338.Web, :view
  def sort_most_recent(query) do
    Enum.sort(query, &(&1.process_at >= &2.process_at))
  end

  def after_now?(date_time) do
    case Ecto.DateTime.compare(date_time, Ecto.DateTime.utc) do
      :gt -> true
      :eq -> true
      :lt -> false
    end
  end
end
