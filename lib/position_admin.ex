defmodule Ex338.RosterAdmin do
  @moduledoc false

  alias Ex338.{RosterPosition}

  def add_open_positions_to_teams(fantasy_teams_query) do
    fantasy_teams_query |> Enum.map(&(add_open_positions_to_team(&1)))
  end

  def add_open_positions_to_team(
    %{roster_positions: positions} = fantasy_team_query) do
     {unassigned, positions} = separate_unassigned positions

    positions
    |> add_open_positions
    |> update_fantasy_team(fantasy_team_query)
    |> add_unassigned(unassigned)
  end

  def primary_positions(roster_positions) do
    roster_positions
    |> Enum.reject(&(flex_position?(&1) || unassigned_position?(&1)))
  end

  def flex_and_unassigned_positions(roster_positions) do
    unassigned = roster_positions |> unassigned_positions
    flex       = roster_positions |> flex_positions
    flex ++ unassigned
  end

  defp separate_unassigned(roster_positions) do
    Enum.partition(roster_positions, &(unassigned_position?(&1)))
  end

  defp add_open_positions(roster_positions) do
    roster_positions
    |> format_query_for_merge
    |> merge_open_positions
    |> format_back_to_query
  end

  defp unassigned_position?(roster_position) do
    Regex.match?(~r/Unassigned/, roster_position.position)
  end

  defp flex_position?(roster_position) do
    Regex.match?(~r/Flex/, roster_position.position)
  end

  defp flex_positions(roster_positions) do
    roster_positions
    |> Enum.filter(&(Regex.match?(~r/Flex/, &1.position)))
  end

  defp unassigned_positions(roster_positions) do
    roster_positions
    |> Enum.filter(&(Regex.match?(~r/Unassigned/, &1.position)))
  end

  defp format_query_for_merge(roster_positions) do
    Enum.reduce roster_positions, %{}, fn(p, acc) ->
      Map.put(acc, p.position, %{
        fantasy_player: %{player_name: p.fantasy_player.player_name,
          sports_league: %{abbrev: p.fantasy_player.sports_league.abbrev}}})
    end
  end

  defp merge_open_positions(roster_positions) do
    Map.merge(open_positions_map, roster_positions)
  end

  defp open_positions_map do
    Enum.reduce RosterPosition.positions, %{}, fn(position, map) ->
      Map.put(map, position, %{
        fantasy_player: %{player_name: "",
          sports_league: %{abbrev: ""}}})
    end
  end

  defp format_back_to_query(map) do
    Enum.reduce map, [], fn({k, v}, acc) ->
      [ %{position: k, fantasy_player: v.fantasy_player} | acc ]
    end
  end

  defp update_fantasy_team(positions, fantasy_team_query) do
    Map.put(fantasy_team_query, :roster_positions, positions)
  end

  defp add_unassigned(%{roster_positions: positions} = query, unassigned) do
    positions = positions ++ unassigned
    Map.put(query, :roster_positions, positions)
  end
end
