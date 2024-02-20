defmodule Ex338Web.ArchivedLeagueHTML do
  use Ex338Web, :html

  alias Ex338Web.Components.FantasyLeague

  def index(assigns) do
    ~H"""
    <div class="flex flex-row flex-wrap justify-center lg:justify-between">
      <FantasyLeague.small_standings_table
        fantasy_leagues={@fantasy_leagues}
        current_user={@current_user}
      />
    </div>
    """
  end
end
