defmodule Ex338.FantasyLeagues.FantasyLeagueAdmin do
  @moduledoc false
  def form_fields(_) do
    [
      fantasy_league_name: nil,
      year: nil,
      division: nil,
      navbar_display: %{choices: navbar_display_options()},
      championships_start_at: nil,
      championships_end_at: nil,
      max_flex_spots: nil,
      only_flex?: nil,
      must_draft_each_sport?: nil,
      draft_method: %{choices: draft_method_options()},
      max_draft_hours: nil,
      draft_picks_locked?: nil,
      sport_draft_id: %{
        label: "Select Sport With Active InSeason Draft",
        choices: [{"None", nil}] ++ Ex338.FantasyPlayers.list_sport_options()
      }
    ]
  end

  defp navbar_display_options do
    Enum.filter(FantasyLeagueNavbarDisplayEnum.__valid_values__(), &is_binary/1)
  end

  defp draft_method_options do
    Enum.filter(FantasyLeagueDraftMethodEnum.__valid_values__(), &is_binary/1)
  end
end
