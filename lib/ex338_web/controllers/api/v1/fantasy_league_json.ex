defmodule Ex338Web.Api.V1.FantasyLeagueJSON do
  def index(%{fantasy_leagues: fantasy_leagues}) do
    %{fantasy_leagues: Enum.map(fantasy_leagues, &league_data/1)}
  end

  def show(%{fantasy_league: league, standings: standings}) do
    %{
      fantasy_league:
        Map.put(league_data(league), :standings, Enum.map(standings, &standing_data/1))
    }
  end

  defp league_data(league) do
    %{
      id: league.id,
      fantasy_league_name: league.fantasy_league_name,
      year: league.year,
      division: league.division,
      navbar_display: league.navbar_display,
      draft_method: league.draft_method,
      max_flex_spots: league.max_flex_spots,
      championships_start_at: league.championships_start_at,
      championships_end_at: league.championships_end_at
    }
  end

  defp standing_data(team) do
    %{
      fantasy_team_id: team.id,
      team_name: team.team_name,
      rank: team.rank,
      points: team.points,
      winnings: team.winnings,
      waiver_position: team.waiver_position
    }
  end
end
