defmodule Ex338Web.FantasyPlayerHTML do
  use Ex338Web, :html

  def index(assigns) do
    ~H"""
    <div class="mb-6 md:flex md:items-center md:justify-start">
      <.page_header>
        Fantasy Players
      </.page_header>

      <div class="flex md:ml-8">
        <.input
          type="select"
          id="sport-filter"
          name="select_sport[select_sport]"
          prompt="Show All"
          class="mt-1 form-select block w-full pl-3 pr-10 py-2 text-base leading-6 border-gray-300 focus:outline-none focus:shadow-outline-indigo focus:border-indigo-300 sm:text-sm sm:leading-5"
          options={format_sports_for_select(@fantasy_players)}
          value=""
        />
      </div>
    </div>

    <div class="grid grid-cols-1 gap-4 lg:grid-cols-2">
      <%= for {sports_league, players} <- @fantasy_players do %>
        <div class="min-w-full fantasy-player-collection" id={abbrev_from_players(players)}>
          <div class="max-w-md mb-10 overflow-hidden bg-white shadow sm:rounded-lg">
            <div class="min-w-full py-5 sm:p-6">
              <div class="px-4 pb-5 bg-white sm:px-6">
                <div class="flex flex-row items-center">
                  <h3 class="text-lg font-medium text-gray-900 sm:mr-2 leading-6">
                    <%= sports_league.league_name %>
                  </h3>
                  <div class="w-6 h-6 text-gray-500">
                    <%= deadline_icon_for_sports_league(sports_league) %>
                  </div>
                </div>
                <p class="mt-1 text-sm text-gray-500 leading-5">
                  Championship on <%= display_championship_date(sports_league) %>
                </p>
              </div>
              <.legacy_table>
                <thead>
                  <tr>
                    <.legacy_th>
                      Player (Final Rank)
                    </.legacy_th>
                    <.legacy_th>
                      Fantasy Team Owner
                    </.legacy_th>
                  </tr>
                </thead>
                <tbody class="bg-white">
                  <%= for player <- players do %>
                    <tr>
                      <%= if get_result(player) do %>
                        <.legacy_td class="font-medium text-gray-900">
                          <%= "#{player.player_name} (#{get_result(player).rank})" %>
                        </.legacy_td>
                      <% else %>
                        <.legacy_td>
                          <%= player.player_name %>
                        </.legacy_td>
                      <% end %>

                      <%= if get_team(player) do %>
                        <.legacy_td class="text-indigo-700">
                          <.fantasy_team_name_link fantasy_team={get_team(player)} />
                        </.legacy_td>
                      <% else %>
                        <.legacy_td>
                          --
                        </.legacy_td>
                      <% end %>
                    </tr>
                  <% end %>
                </tbody>
              </.legacy_table>
            </div>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

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
