defmodule Ex338Web.DraftPickView do
  use Ex338Web, :view

  def next_pick?(draft_picks, draft_pick) do
    Enum.find(draft_picks, &(&1.fantasy_player_id == nil)) == draft_pick
  end
end
