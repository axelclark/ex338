defmodule Ex338Web.TradeView do
  use Ex338Web, :view

  alias Ex338.Trades.Trade

  def allow_vote?(
        %{status: "Pending", trade_votes: votes},
        %{fantasy_teams: teams},
        fantasy_league
      ) do
    do_allow_vote?(votes, teams, fantasy_league)
  end

  def allow_vote?(
        %{status: "Proposed", trade_votes: votes},
        %{fantasy_teams: teams},
        fantasy_league
      ) do
    do_allow_vote?(votes, teams, fantasy_league)
  end

  def allow_vote?(_trade, _current_user, _fantasy_league), do: false

  def get_team_for_league([], _fantasy_league), do: :no_team

  def get_team_for_league(teams, fantasy_league) do
    case Enum.filter(teams, &(&1.fantasy_league_id == fantasy_league.id)) do
      [team] -> team
      [] -> :no_team
      _other -> raise "User owns two teams in league"
    end
  end

  def proposed_for_team?(%{status: "Proposed"}, %{admin: true}), do: true

  def proposed_for_team?(%{status: "Proposed"} = trade, %{fantasy_teams: teams}) do
    Enum.any?(teams, fn team ->
      trade
      |> Trade.get_teams_from_trade()
      |> match_any_team?(team)
    end)
  end

  def proposed_for_team?(_trade, _current_user), do: false

  ## Helpers

  # allow_vote?

  defp do_allow_vote?(votes, teams, fantasy_league) do
    case get_team_for_league(teams, fantasy_league) do
      :no_team -> false
      team -> team_has_not_voted?(votes, team)
    end
  end

  def team_has_not_voted?(votes, team) do
    !Enum.any?(votes, &(&1.fantasy_team_id == team.id))
  end

  # proposed_for_team

  defp match_any_team?(teams, team) do
    Enum.any?(teams, &(&1.id == team.id))
  end
end
