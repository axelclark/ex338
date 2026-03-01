defmodule Ex338Web.Api.V1.DraftPickJSON do
  def index(%{draft_picks: draft_picks}) do
    %{draft_picks: Enum.map(draft_picks, &draft_pick_data/1)}
  end

  defp draft_pick_data(pick) do
    %{
      id: pick.id,
      draft_position: pick.draft_position,
      pick_number: pick.pick_number,
      fantasy_team: %{
        id: pick.fantasy_team.id,
        team_name: pick.fantasy_team.team_name
      },
      fantasy_player: player_data(pick.fantasy_player),
      drafted_at: pick.drafted_at,
      is_keeper: pick.is_keeper
    }
  end

  defp player_data(%{id: id} = player) do
    %{
      id: id,
      player_name: player.player_name,
      sports_league: player.sports_league.abbrev
    }
  end

  defp player_data(_), do: nil
end
