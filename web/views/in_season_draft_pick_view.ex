defmodule Ex338.InSeasonDraftPickView do
  use Ex338.Web, :view

  def format_players_as_options(players) do
    Enum.map(players, &(format_player_as_option(&1)))
  end

  defp format_player_as_option(player), do: {player.player_name, player.id}
end
