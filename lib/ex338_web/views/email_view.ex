defmodule Ex338Web.EmailView do
  use Ex338Web, :view

  def display_player(%{player_name: name, sports_league: %{abbrev: abbrev}}),
    do: "#{String.trim(name)}, #{abbrev}"
end
