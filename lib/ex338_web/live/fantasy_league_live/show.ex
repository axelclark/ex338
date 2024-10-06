defmodule Ex338Web.FantasyLeagueLive.Show do
  @moduledoc false
  use Ex338Web, :live_view

  alias Ex338.FantasyLeagues
  alias Ex338.FantasyTeams

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    fantasy_league = FantasyLeagues.get(id)

    {:noreply,
     socket
     |> assign(:fantasy_league, fantasy_league)
     |> assign(:standings_chart_data, FantasyTeams.list_standings_history(fantasy_league))
     |> assign(:fantasy_teams, FantasyTeams.find_all_for_standings(fantasy_league))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page_header class="sm:mb-6">
        Standings
      </.page_header>

      <div class="flex flex-col">
        <div class="pb-6">
          <div class="py-2 -my-2 overflow-x-visible sm:-mx-6 sm:px-6 lg:-mx-8 lg:px-8">
            <div class="inline-block min-w-full overflow-hidden align-middle border-b border-gray-200 shadow sm:rounded-lg">
              <table class="min-w-full">
                <thead>
                  <tr>
                    <th class="px-2 py-3 text-xs font-medium tracking-wider text-left text-gray-500 uppercase border-b border-gray-200 sm:px-6 bg-gray-50 lg:text-sm leading-4">
                      Rank
                    </th>
                    <th class="px-2 py-3 text-xs font-medium tracking-wider text-left text-gray-500 uppercase border-b border-gray-200 sm:px-6 bg-gray-50 lg:text-sm leading-4">
                      Name
                    </th>
                    <th class="px-2 py-3 text-xs font-medium tracking-wider text-center text-gray-500 uppercase border-b border-gray-200 sm:px-6 bg-gray-50 lg:text-sm leading-4">
                      Points
                    </th>
                    <th class="hidden px-2 py-3 text-xs font-medium tracking-wider text-center text-gray-500 uppercase border-b border-gray-200 sm:table-cell sm:px-6 whitespace-wrap bg-gray-50 lg:text-sm leading-4">
                      Waiver Position
                    </th>
                    <th class="px-2 py-3 text-xs font-medium tracking-wider text-center text-gray-500 uppercase border-b border-gray-200 sm:hidden sm:px-6 whitespace-wrap bg-gray-50 lg:text-sm leading-4">
                      Waiver
                    </th>
                    <th class="px-2 py-3 text-xs font-medium tracking-wider text-center text-gray-500 uppercase border-b border-gray-200 sm:px-6 bg-gray-50 lg:text-sm leading-4">
                      Winnings
                    </th>
                    <th class="hidden py-3 text-xs font-medium tracking-wider text-center text-gray-500 uppercase border-b border-gray-200 sm:table-cell sm:px-6 bg-gray-50 lg:text-sm leading-4">
                      Dues
                    </th>
                  </tr>
                </thead>
                <tbody class="bg-white">
                  <%= for team <- @fantasy_teams do %>
                    <tr>
                      <td class="px-1 py-2 text-sm text-center text-gray-500 whitespace-no-wrap border-b border-gray-200 sm:px-6 lg:text-base sm:text-left leading-5">
                        <%= team.rank %>
                      </td>
                      <td
                        class="px-1 py-2 text-sm font-medium text-indigo-700 break-words border-b border-gray-200 sm:px-6 lg:text-base leading-5"
                        style="word-break: break-word;"
                      >
                        <.link href={~p"/fantasy_teams/#{team.id}"}>
                          <%= team.team_name %>
                        </.link>
                      </td>
                      <td class="px-1 py-2 text-sm text-center text-gray-500 whitespace-no-wrap border-b border-gray-200 sm:px-6 lg:text-base leading-5">
                        <%= team.points %>
                      </td>
                      <td class="px-1 py-2 text-sm text-center text-gray-500 whitespace-no-wrap border-b border-gray-200 sm:px-6 lg:text-base leading-5">
                        <%= team.waiver_position %>
                      </td>
                      <td class="px-1 py-2 text-sm text-center text-gray-500 whitespace-no-wrap border-b border-gray-200 sm:px-6 lg:text-base leading-5">
                        <%= format_whole_dollars(team.winnings) %>
                      </td>
                      <td class="hidden py-2 text-sm text-center text-gray-500 whitespace-no-wrap border-b border-gray-200 sm:table-cell sm:px-6 lg:text-base leading-5">
                        <%= format_whole_dollars(team.dues_paid) %>
                      </td>
                    </tr>
                  <% end %>
                </tbody>
              </table>
            </div>
          </div>
        </div>
        <div class="pb-6">
          <.calendar_download fantasy_league={@fantasy_league} />
        </div>
      </div>
      <.live_component
        module={Ex338Web.FantasyLeagueLive.StandingsChartComponent}
        id="standings-chart"
        standings_chart_data={@standings_chart_data}
      />
    </div>
    """
  end

  defp calendar_download(assigns) do
    ~H"""
    <div class="border-b border-gray-200 bg-white px-4 py-5 sm:px-6 shadow sm:rounded-lg">
      <div class="-ml-4 -mt-4 flex flex-wrap items-center justify-between sm:flex-nowrap">
        <div class="ml-4 mt-4">
          <h3 class="text-base font-semibold leading-6 text-gray-900">Download League Calendar</h3>
          <p class="mt-1 text-sm text-gray-500">
            Download an ICS file to add key dates to your calendar. These are all-day events, so
            you'll need to check the championships page for the specific deadline times.
          </p>
        </div>
        <div class="ml-4 mt-4 flex-shrink-0">
          <.link
            href={~p"/fantasy_leagues/#{@fantasy_league.id}/calendar_download"}
            class="w-full relative inline-flex items-center rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600"
          >
            Download
          </.link>
        </div>
      </div>
    </div>
    """
  end
end
