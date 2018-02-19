defmodule Ex338.RosterPosition.OpenPosition do
  @moduledoc false

  alias Ex338.{RosterPosition.RosterAdmin}

  def add_open_positions_to_teams(fantasy_teams, league_positions) do
     Enum.map(fantasy_teams, &(add_open_positions_to_team(&1, league_positions)))
  end

  def add_open_positions_to_team(
    %{roster_positions: positions} = fantasy_team, league_positions
  ) do
     {unassigned, positions} = separate_unassigned(positions)

    positions
    |> add_open_positions(league_positions)
    |> RosterAdmin.update_fantasy_team(fantasy_team)
    |> add_unassigned(unassigned)
  end

  defp separate_unassigned(roster_positions) do
    Enum.split_with(roster_positions,
     &(RosterAdmin.unassigned_position?(&1.position)))
  end

  defp add_open_positions(roster_positions, league_positions) do
    roster_positions
    |> format_positions_for_merge
    |> merge_open_positions(league_positions)
    |> return_position_key_into_map
  end

  defp format_positions_for_merge(roster_positions) do
    Enum.reduce roster_positions, %{}, fn(p, acc) ->
      Map.put(acc, p.position, %{fantasy_player: p.fantasy_player})
    end
  end

  defp merge_open_positions(roster_positions, league_positions) do
    Map.merge(open_positions_map(league_positions), roster_positions)
  end

  defp open_positions_map(league_positions) do
    Enum.reduce league_positions, %{}, fn(position, map) ->
      Map.put(map, position, %{
        fantasy_player: %{player_name: "",
          sports_league: %{abbrev: ""},
          championship_results: []
        }
      })
    end
  end

  defp return_position_key_into_map(map) do
    Enum.reduce map, [], fn({k, v}, acc) ->
      [%{position: k, fantasy_player: v.fantasy_player} | acc]
    end
  end

  defp add_unassigned(%{roster_positions: positions} = query, unassigned) do
    positions = positions ++ unassigned
    Map.put(query, :roster_positions, positions)
  end
end
