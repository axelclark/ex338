defmodule Ex338Web.TradeView do
  use Ex338Web, :view

  def allow_vote?(%{status: "Pending", trade_votes: votes}, %{fantasy_teams: [team]}) do
    team_has_not_voted?(votes, team)
  end

  def allow_vote?(%{status: "Proposed", trade_votes: votes}, %{fantasy_teams: [team]}) do
    team_has_not_voted?(votes, team)
  end

  def allow_vote?(_trade, _current_user), do: false

  def get_team(%{fantasy_teams: [team]}), do: team

  def get_team(%{fantasy_teams: []}), do: :no_team

  def proposed_for_team?(%{status: "Proposed"}, %{admin: true}), do: true

  def proposed_for_team?(%{status: "Proposed"} = trade, %{fantasy_teams: [team]}) do
    trade
    |> teams_in_trade()
    |> match_any_team?(team)
  end

  def proposed_for_team?(_trade, _current_user), do: false

  ## Helpers

  # allow_vote?

  def team_has_not_voted?(votes, team) do
    !Enum.any?(votes, &(&1.fantasy_team_id == team.id))
  end

  # proposed_for_team

  defp match_any_team?(teams, team) do
    Enum.any?(teams, &(&1.id == team.id))
  end

  defp teams_in_trade(trade) do
    teams =
      trade.trade_line_items
      |> Enum.reduce([], fn item, acc ->
        [item.gaining_team] ++ [item.losing_team]
      end)
      |> Enum.uniq_by(& &1.id)
  end
end
