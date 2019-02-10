defmodule Ex338Web.DraftPickView do
  use Ex338Web, :view

  def next_pick?(draft_picks, draft_pick) do
    Enum.find(draft_picks, &(&1.fantasy_player_id == nil)) == draft_pick
  end

  def seconds_to_hours(seconds) do
    Float.floor(seconds / 3600, 2)
  end

  def seconds_to_mins(seconds) do
    Float.floor(seconds / 60, 2)
  end
end
