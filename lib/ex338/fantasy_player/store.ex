defmodule Ex338.FantasyPlayer.Store do
  @moduledoc false

  alias Ex338.{FantasyTeam, FantasyPlayer, Repo}

  def all_plyrs_for_lg(league_id) do
    league_id
    |> FantasyTeam.right_join_players_by_league
    |> Repo.all
    |> Enum.group_by(fn %{league_name: league_name} -> league_name end)
  end

  def available_players(fantasy_league_id) do
    fantasy_league_id
    |> FantasyPlayer.available_players
    |> Repo.all
  end
end
