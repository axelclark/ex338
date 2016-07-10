defmodule Ex338.Factory do
  @moduledoc """
  Defines factories for creating test data
  """

  use ExMachina.Ecto, repo: Ex338.Repo

  def fantasy_league_factory do
    %Ex338.FantasyLeague{
      division: sequence(:division, &"Div#{&1}"),
      year: 2017,
    }
  end

  def fantasy_team_factory do
    %Ex338.FantasyTeam{
      team_name: sequence(:team_name, &"Team ##{&1}"),
      fantasy_league: [build(:fantasy_league)],
    }
  end

  def sports_league_factory do
    %Ex338.SportsLeague{league_name: sequence(:league_name, &"League ##{&1}")}
  end

  def fantasy_player_factory do
    %Ex338.FantasyPlayer{
      player_name:  sequence(:player_name, &"Player ##{&1}"),
      sports_league: [build(:sports_league)],
    }
  end
end
