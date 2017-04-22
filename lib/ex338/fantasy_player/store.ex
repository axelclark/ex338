defmodule Ex338.FantasyPlayer.Store do
  @moduledoc false

  alias Ex338.{FantasyTeam, Repo}

  def all_plyrs_for_lg(league_id) do
    league_id
    |> FantasyTeam.right_join_players_by_league
    |> Repo.all
    |> Enum.group_by(fn %{league_name: league_name} -> league_name end)
  end
end
