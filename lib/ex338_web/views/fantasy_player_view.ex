defmodule Ex338Web.FantasyPlayerView do
  use Ex338Web, :view

  def format_sports_for_select(players) do
    players
    |> Enum.flat_map(fn {_league, players} -> players end)
    |> Enum.uniq_by(fn %{league_abbrev: abbrev} -> abbrev end)
    |> Enum.map(&format_select_data/1)
  end

  def abbrev_from_players([player | _rest]) do
    player.league_abbrev
  end

  ## Helpers

  ## format_sport_select

  defp format_select_data(player) do
    [key: player.league_name, value: player.league_abbrev]
  end
end
