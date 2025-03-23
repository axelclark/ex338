defmodule Ex338Web.PageHTML do
  use Ex338Web, :html

  alias Ex338Web.Components.FantasyLeague

  def index(assigns) do
    ~H"""
    <div>
      <.announcements />
      <section>
        <div class="flex flex-row flex-wrap justify-between">
          <FantasyLeague.small_standings_table
            fantasy_leagues={@fantasy_leagues}
            current_user={@current_user}
          />
        </div>
      </section>
      <section>
        <h2 class="pt-4 pb-4 text-lg text-center text-gray-700 sm:pb-6 sm:pt-10 sm:text-2xl ">
          Historical Records
        </h2>
        <div class="sm:justify-center sm:flex-wrap sm:flex-row sm:flex md:justify-around">
          <.season_records_table season_records={@season_records} />
          <.all_time_records_table all_time_records={@all_time_records} />
          <.winnings_table winnings={@winnings} />
        </div>
      </section>
    </div>
    """
  end

  defp announcements(assigns) do
    ~H"""
    <div class="mb-6 sm:mb-10 bg-white overflow-hidden shadow sm:rounded-lg">
      <div class="border-b border-gray-200 px-4 py-5 sm:px-6">
        <!-- Content goes here -->
        <div class="flex items-center">
          <svg
            class="flex-shrink-0 -ml-1 mr-3 h-6 w-6 text-gray-400 transition ease-in-out duration-150"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
          >
            <path d="M7 8h10M7 12h4m1 8l-4-4H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-3l-4 4z">
            </path>
          </svg>
          League Announcements
        </div>
        <!-- We use less vertical padding on card headers on desktop than on body sections -->
      </div>
      <div class="px-4 py-5 sm:p-6">
        <!-- Content goes here -->
        <p class="text-gray-700 text-sm">
          <b>
            Click
            <.link class="text-indigo-700" href={Application.get_env(:ex338, :slack_invite_url)}>
              here
            </.link>
            to request a Slack invite.
          </b>
          League messsages, trash talk, trade discussions, etc. are done in the Slack channel.
        </p>
      </div>
    </div>
    """
  end

  attr :season_records, :list, required: true

  defp season_records_table(assigns) do
    ~H"""
    <div class="pb-6 md:max-w-4xl">
      <div class="-my-2 py-2 overflow-x-auto sm:-mx-6 sm:px-6 lg:-mx-8 lg:px-8">
        <div class="align-middle inline-block min-w-full shadow overflow-hidden sm:rounded-lg border-b border-gray-200">
          <table class="min-w-full">
            <thead>
              <tr>
                <th class="px-4 sm:px-6 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase tracking-wider">
                  Single Season Records
                </th>
                <th class="px-4 sm:px-6 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase tracking-wider">
                  Record
                </th>
                <th class="px-4 sm:px-6 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase tracking-wider">
                  Team
                </th>
                <th class="px-4 sm:px-6 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase tracking-wider">
                  Year
                </th>
              </tr>
            </thead>
            <tbody class="bg-white">
              <%= for record <- @season_records do %>
                <tr>
                  <td class="px-4 sm:px-6 py-2 whitespace-normal border-b font-medium border-gray-200 text-sm leading-5 text-gray-900">
                    {record.description}
                  </td>
                  <td class="px-4 sm:px-6 py-2 whitespace-normal border-b border-gray-200 text-sm leading-5 text-gray-500">
                    {record.record}
                  </td>
                  <td class="px-4 sm:px-6 py-2 whitespace-normal border-b border-gray-200 text-sm leading-5 text-gray-500">
                    {record.team}
                  </td>
                  <td class="px-4 sm:px-6 py-2 whitespace-no-wrap border-b border-gray-200 text-sm leading-5 text-gray-500">
                    {record.year}
                  </td>
                </tr>
              <% end %>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    """
  end

  attr :all_time_records, :list, required: true

  defp all_time_records_table(assigns) do
    ~H"""
    <div class="pb-6 md:max-w-md">
      <div class="-my-2 py-2 overflow-x-auto sm:-mx-6 sm:px-6 lg:-mx-8 lg:px-8">
        <div class="align-middle inline-block min-w-full shadow overflow-hidden sm:rounded-lg border-b border-gray-200">
          <table class="min-w-full">
            <thead>
              <tr>
                <th class="px-4 sm:px-6 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase tracking-wider">
                  All-Time Records
                </th>
                <th class="px-4 sm:px-6 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase tracking-wider">
                  Record
                </th>
                <th class="px-4 sm:px-6 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase tracking-wider">
                  Team
                </th>
              </tr>
            </thead>
            <tbody class="bg-white">
              <%= for record <- @all_time_records do %>
                <tr>
                  <td class="px-4 sm:px-6 py-2 whitespace-normal font-medium border-b border-gray-200 text-sm leading-5 text-gray-900">
                    {record.description}
                  </td>
                  <td class="px-4 sm:px-6 py-2 whitespace-normal border-b border-gray-200 text-sm leading-5 text-gray-500">
                    {record.record}
                  </td>
                  <td class="px-4 sm:px-6 py-2 whitespace-normal border-b border-gray-200 text-sm leading-5 text-gray-500">
                    {record.team}
                  </td>
                </tr>
              <% end %>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    """
  end

  attr :winnings, :list, required: true

  defp winnings_table(assigns) do
    ~H"""
    <div class="pb-6 min-w-full md:min-w-0 md:max-w-md">
      <div class="-my-2 py-2 overflow-x-auto sm:-mx-6 sm:px-6 lg:-mx-8 lg:px-8">
        <div class="align-middle inline-block min-w-full shadow overflow-hidden sm:rounded-lg border-b border-gray-200">
          <table class="min-w-full">
            <thead>
              <tr>
                <th class="px-4 sm:px-6 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase tracking-wider">
                  All-Time Money List<br />(includes all leagues)
                </th>
                <th class="px-4 sm:px-6 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase tracking-wider">
                  Amount
                </th>
              </tr>
            </thead>
            <tbody class="bg-white">
              <%= for record <- @winnings do %>
                <tr>
                  <td class="px-4 sm:px-6 py-2 whitespace-normal border-b font-medium border-gray-200 text-sm leading-5 text-gray-900">
                    {record.team}
                  </td>
                  <td class="px-4 sm:px-6 py-2 whitespace-normal border-b border-gray-200 text-sm leading-5 text-gray-500">
                    {format_whole_dollars(record.amount)}
                  </td>
                </tr>
              <% end %>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    """
  end

  def rules(assigns) do
    ~H"""
    <div class="flex justify-center">
      <div class="overflow-hidden bg-white shadow sm:rounded-lg">
        <div class="px-4 py-8 mx-auto sm:px-24 sm:py-16 lg:px-32">
          <div class="prose">
            {Phoenix.HTML.raw(@rulebook.body)}
          </div>
          <%= if @current_user do %>
            {live_render(
              @conn,
              Ex338Web.RulesLive,
              session: %{
                "current_user_id" => @current_user.id,
                "fantasy_league_id" => @fantasy_league.id
              }
            )}
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  def rules_path(fantasy_league) do
    case fantasy_league.draft_method do
      :redraft -> "#{fantasy_league.year}_rules.html"
      :keeper -> "#{fantasy_league.year}_keeper_rules.html"
    end
  end
end
