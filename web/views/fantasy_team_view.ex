defmodule Ex338.FantasyTeamView do
  use Ex338.Web, :view

  def sort_by_position(query) do
    Enum.sort(query, &(&1.position <= &2.position))
  end
end
