defmodule Ex338Web.TradeView do
  use Ex338Web, :view

  def allow_vote?(
    %{status: "Pending", trade_votes: votes},
    %{fantasy_teams: [team]}
  ) do
    team_has_not_voted?(votes, team)
  end

  def allow_vote?(_trade, _current_user), do: false

  def get_team(%{fantasy_teams: [team]}), do: team

  def get_team(%{fantasy_teams: []}), do: :no_team

  ## Helpers

  # allow_vote?

  def team_has_not_voted?(votes, team) do
    !Enum.any?(votes, &(&1.fantasy_team_id) == team.id)
  end

end
