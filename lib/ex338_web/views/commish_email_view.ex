defmodule Ex338Web.CommishEmailView do
  use Ex338Web, :view

  def format_leagues_for_select(leagues) do
    Enum.map leagues, fn(league) ->
      name = String.to_atom(league.fantasy_league_name)
      {name, league.id}
    end
  end
end
