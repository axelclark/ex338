defmodule Ex338Web.Components.FantasyLeague do
  @moduledoc """
  Provides fantasy league UI components.
  """
  use Phoenix.Component

  use Phoenix.VerifiedRoutes,
    endpoint: Ex338Web.Endpoint,
    router: Ex338Web.Router

  import Ex338Web.HTMLHelpers

  attr :fantasy_leagues, :list, required: true
  attr :current_user, :map, required: true

  def small_standings_table(assigns) do
    ~H"""
    <%= for league <- @fantasy_leagues do %>
      <div class="pb-6 md:max-w-md">
        <header>
          <div class="flex items-center justify-between">
            <div class="flex-1 min-w-0">
              <h2 class="py-2 pl-4 text-lg text-indigo-700 sm:pl-6">
                <.link href={~p"/fantasy_leagues/#{league.id}"}>
                  {league.fantasy_league_name}
                </.link>
              </h2>
            </div>
            <div class="flex pr-4 sm:pr-6">
              <%= if admin?(@current_user) do %>
                <span class="inline-flex rounded-md shadow-sm">
                  <.link
                    href={~p"/commish/fantasy_leagues/#{league}/approvals"}
                    class="inline-flex items-center px-2.5 py-1.5 border border-gray-300 text-xs leading-4 font-medium rounded text-gray-700 bg-white hover:text-gray-500 focus:outline-none focus:border-blue-300 focus:shadow-outline-blue active:text-gray-800 active:bg-gray-50 transition ease-in-out duration-150"
                  >
                    Commish Actions
                  </.link>
                </span>
              <% end %>
            </div>
          </div>
        </header>
        <div class="py-2 -my-2 overflow-x-auto sm:-mx-6 sm:px-6 lg:-mx-8 lg:px-8">
          <div class="inline-block min-w-full overflow-hidden align-middle border-b border-gray-200 shadow sm:rounded-lg">
            <table class="min-w-full">
              <thead>
                <tr>
                  <th class="px-4 py-3 text-xs font-medium tracking-wider text-left text-gray-500 uppercase border-b border-gray-200 sm:px-6 bg-gray-50 leading-4">
                    Rank
                  </th>
                  <th class="px-4 py-3 text-xs font-medium tracking-wider text-left text-gray-500 uppercase border-b border-gray-200 sm:px-6 bg-gray-50 leading-4">
                    Name
                  </th>
                  <th class="px-4 py-3 text-xs font-medium tracking-wider text-center text-gray-500 uppercase border-b border-gray-200 sm:px-6 bg-gray-50 leading-4">
                    Points
                  </th>
                  <th class="px-4 py-3 text-xs font-medium tracking-wider text-center text-gray-500 uppercase border-b border-gray-200 sm:px-6 bg-gray-50 leading-4">
                    Winnings
                  </th>
                </tr>
              </thead>
              <tbody class="bg-white">
                <%= for team <- league.fantasy_teams do %>
                  <tr>
                    <td class="px-4 py-2 text-sm text-center text-gray-500 whitespace-no-wrap border-b border-gray-200 sm:px-6 leading-5">
                      {team.rank}
                    </td>
                    <td
                      class="px-4 py-2 text-sm font-medium text-indigo-700 break-words border-b border-gray-200 sm:px-6 leading-5"
                      style="word-break: break-word;"
                    >
                      <.link href={~p"/fantasy_teams/#{team.id}"}>
                        {team.team_name}
                      </.link>
                    </td>
                    <td class="px-4 py-2 text-sm text-center text-gray-500 whitespace-no-wrap border-b border-gray-200 sm:px-6 leading-5">
                      {team.points}
                    </td>
                    <td class="px-4 py-2 text-sm text-center text-gray-500 whitespace-no-wrap border-b border-gray-200 sm:px-6 leading-5">
                      {format_whole_dollars(team.winnings)}
                    </td>
                  </tr>
                <% end %>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    <% end %>
    """
  end
end
