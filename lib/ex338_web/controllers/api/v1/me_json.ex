defmodule Ex338Web.Api.V1.MeJSON do
  def show(%{user: user}) do
    %{user: user_data(user)}
  end

  defp user_data(user) do
    %{
      id: user.id,
      name: user.name,
      email: user.email,
      admin: user.admin,
      fantasy_teams: Enum.map(user.fantasy_teams, &team_data/1)
    }
  end

  defp team_data(team) do
    %{
      id: team.id,
      team_name: team.team_name,
      fantasy_league: league_data(team.fantasy_league)
    }
  end

  defp league_data(%{id: id} = league) do
    %{
      id: id,
      fantasy_league_name: league.fantasy_league_name,
      division: league.division,
      year: league.year
    }
  end

  defp league_data(_not_loaded), do: nil
end
