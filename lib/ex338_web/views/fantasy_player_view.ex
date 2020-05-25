defmodule Ex338Web.FantasyPlayerView do
  use Ex338Web, :view

  def abbrev_from_players([player | _rest]) do
    player.sports_league.abbrev
  end

  def deadline_icon_for_sports_league(%{championships: [championship]}) do
    Ex338Web.ViewHelpers.transaction_deadline_icon(championship)
  end

  def deadline_icon_for_sports_league(_), do: ""

  def display_championship_date(%{championships: [championship]}) do
    short_date_pst(championship.championship_at)
  end

  def display_championship_date(_), do: ""

  def format_sports_for_select(players) do
    players
    |> Enum.flat_map(fn {_league, players} -> players end)
    |> Enum.uniq_by(fn %{sports_league_id: sport_id} -> sport_id end)
    |> Enum.map(&format_select_data/1)
  end

  def get_result(%{championship_results: [result]}), do: result
  def get_result(%{championship_results: []}), do: nil

  def get_team(%{roster_positions: [position]}), do: position.fantasy_team
  def get_team(%{roster_positions: []}), do: nil

  ## Helpers

  ## format_sport_select

  defp format_select_data(player) do
    [key: player.sports_league.league_name, value: player.sports_league.abbrev]
  end
end
