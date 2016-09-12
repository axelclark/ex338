defmodule Ex338.DraftPickView do
  use Ex338.Web, :view

  def next_pick?(draft_picks, draft_pick) do
    Enum.find(draft_picks, &(&1.fantasy_player_id == nil)) == draft_pick
  end

  def owner?(current_user, draft_pick) do
    draft_pick.fantasy_team.owners
    |> Enum.any?(&(&1.user_id == current_user.id))
  end
end
