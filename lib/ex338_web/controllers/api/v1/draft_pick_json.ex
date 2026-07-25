defmodule Ex338Web.Api.V1.DraftPickJSON do
  def index(%{draft_picks: draft_picks}) do
    %{draft_picks: Enum.map(draft_picks, &draft_pick_data/1)}
  end

  # `pick_number` counts a pick's place among all of a league's picks, so it is only
  # known when the whole board is loaded. Omitted rather than reported as null, so a
  # client caching a write response can't overwrite a real pick number with nothing.
  def show(%{draft_pick: draft_pick}) do
    %{draft_pick: draft_pick |> draft_pick_data() |> Map.delete(:pick_number)}
  end

  defp draft_pick_data(pick) do
    %{
      id: pick.id,
      draft_position: pick.draft_position,
      pick_number: pick.pick_number,
      fantasy_team: team_data(pick.fantasy_team),
      fantasy_player: player_data(pick.fantasy_player),
      drafted_at: pick.drafted_at,
      is_keeper: pick.is_keeper
    }
  end

  defp team_data(%{id: id} = team), do: %{id: id, team_name: team.team_name}

  defp team_data(_), do: nil

  defp player_data(%{id: id} = player) do
    %{
      id: id,
      player_name: player.player_name,
      sports_league: player.sports_league.abbrev
    }
  end

  defp player_data(_), do: nil
end
