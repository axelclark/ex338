defmodule Ex338.WaiverView do
  use Ex338.Web, :view
  def sort_most_recent(query) do
    Enum.sort(query, &(&1.process_at >= &2.process_at))
  end
end
