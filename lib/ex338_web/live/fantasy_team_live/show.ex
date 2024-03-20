defmodule Ex338Web.FantasyTeamLive.Show do
  @moduledoc false
  use Ex338Web, :live_view

  import Ex338Web.FantasyTeamComponents

  alias Ex338.FantasyTeams

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    fantasy_team = FantasyTeams.find(id)

    {:noreply,
     socket
     |> assign(:fantasy_team, fantasy_team)
     |> assign(:fantasy_league, fantasy_team.fantasy_league)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="overflow-hidden bg-white shadow sm:rounded-lg">
      <div class="px-4 py-5 border-b border-gray-200 sm:px-6">
        <h3 class="text-lg font-medium text-indigo-800 leading-6">
          <%= @fantasy_team.team_name %>
        </h3>
        <p class="max-w-2xl mt-1 text-sm text-gray-500 leading-5">
          Owned by
          <%= for owner <- @fantasy_team.owners do %>
            <span>
              <.link href={~p"/users/#{owner.user.id}"} class="no-underline hover:underline">
                <%= owner.user.name %>
              </.link>
            </span>
          <% end %>
        </p>
      </div>
      <div class="px-4 py-5 sm:px-6">
        <dl class="grid grid-cols-1 gap-y-4 gap-x-4 sm:gap-x-6 sm:grid-cols-2">
          <div class="sm:col-span-1">
            <dt class="text-sm font-medium text-gray-500 leading-5">
              Waiver Position
            </dt>
            <dd class="mt-1 text-sm text-gray-900 leading-5">
              <%= @fantasy_team.waiver_position %>
            </dd>
          </div>
          <div class="sm:col-span-1">
            <dt class="text-sm font-medium text-gray-500 leading-5">
              Queue Autodraft
            </dt>
            <dd class="mt-1 text-sm text-gray-900 leading-5">
              <%= FantasyTeams.display_autodraft_setting(@fantasy_team) %>
            </dd>
          </div>
          <div class="sm:col-span-1">
            <dt class="text-sm font-medium text-gray-500 leading-5">
              Winnings / Received
            </dt>
            <dd class="mt-1 text-sm text-gray-900 leading-5">
              <%= format_whole_dollars(@fantasy_team.winnings) %> / <%= format_whole_dollars(
                @fantasy_team.winnings_received
              ) %>
            </dd>
          </div>
          <div class="sm:col-span-1">
            <dt class="text-sm font-medium text-gray-500 leading-5">
              Dues Paid
            </dt>
            <dd class="mt-1 text-sm text-gray-900 leading-5">
              <%= format_whole_dollars(@fantasy_team.dues_paid) %>
            </dd>
          </div>
          <%= if (owner?(@current_user, @fantasy_team) || admin?(@current_user)) do %>
            <div class="sm:col-span-2">
              <dt class="text-sm font-medium text-gray-500 leading-5">
                Owner Actions
              </dt>
              <dd class="mt-1 text-sm text-gray-900 leading-5">
                <ul class="border border-gray-200 rounded-md">
                  <li class="flex items-center justify-between py-3 pl-3 pr-4 text-sm leading-5">
                    <div class="flex items-center flex-1 w-0">
                      <svg
                        class="flex-shrink-0 w-5 h-5 text-gray-400"
                        fill="none"
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        viewBox="0 0 20 20"
                        stroke="currentColor"
                      >
                        <path d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z">
                        </path>
                      </svg>
                      <span class="flex-1 w-0 ml-2 truncate">
                        Update team and roster
                      </span>
                    </div>
                    <div class="flex-shrink-0 ml-4">
                      <.link
                        href={~p"/fantasy_teams/#{@fantasy_team.id}/edit"}
                        class="font-medium text-indigo-600 hover:text-indigo-500 transition duration-150 ease-in-out"
                      >
                        Update
                      </.link>
                    </div>
                  </li>
                  <li class="flex items-center justify-between py-3 pl-3 pr-4 text-sm border-t border-gray-200 leading-5">
                    <div class="flex items-center flex-1 w-0">
                      <svg
                        class="flex-shrink-0 w-5 h-5 text-gray-400"
                        fill="none"
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        viewBox="0 0 24 24"
                        stroke="currentColor"
                      >
                        <path d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z">
                        </path>
                      </svg>
                      <span class="flex-1 w-0 ml-2 truncate">
                        Create a new waiver claim
                      </span>
                    </div>
                    <div class="flex-shrink-0 ml-4">
                      <.link
                        href={~p"/fantasy_teams/#{@fantasy_team.id}/waivers/new"}
                        class="font-medium text-indigo-600 hover:text-indigo-500 transition duration-150 ease-in-out"
                      >
                        Create Waiver
                      </.link>
                    </div>
                  </li>
                  <li class="flex items-center justify-between py-3 pl-3 pr-4 text-sm border-t border-gray-200 leading-5">
                    <div class="flex items-center flex-1 w-0">
                      <svg
                        class="flex-shrink-0 w-5 h-5 text-gray-400"
                        fill="none"
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        viewBox="0 0 24 24"
                        stroke="currentColor"
                      >
                        <path d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                      </svg>
                      <span class="flex-1 w-0 ml-2 truncate">
                        Add player to injured reserve
                      </span>
                    </div>
                    <div class="flex-shrink-0 ml-4">
                      <.link
                        href={~p"/fantasy_teams/#{@fantasy_team.id}/injured_reserves/new"}
                        class="font-medium text-indigo-600 hover:text-indigo-500 transition duration-150 ease-in-out"
                      >
                        Submit IR
                      </.link>
                    </div>
                  </li>
                  <li class="flex items-center justify-between py-3 pl-3 pr-4 text-sm border-t border-gray-200 leading-5">
                    <div class="flex items-center flex-1 w-0">
                      <svg
                        class="flex-shrink-0 w-5 h-5 text-gray-400"
                        fill="none"
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        viewBox="0 0 24 24"
                        stroke="currentColor"
                      >
                        <path d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4"></path>
                      </svg>
                      <span class="flex-1 w-0 ml-2 truncate">
                        Propose a new trade
                      </span>
                    </div>
                    <div class="flex-shrink-0 ml-4">
                      <.link
                        href={~p"/fantasy_teams/#{@fantasy_team.id}/trades/new"}
                        class="font-medium text-indigo-600 hover:text-indigo-500 transition duration-150 ease-in-out"
                      >
                        Propose Trade
                      </.link>
                    </div>
                  </li>
                  <li class="flex items-center justify-between py-3 pl-3 pr-4 text-sm border-t border-gray-200 leading-5">
                    <div class="flex items-center flex-1 w-0">
                      <svg
                        class="flex-shrink-0 w-5 h-5 text-gray-400"
                        fill="none"
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        viewBox="0 0 24 24"
                        stroke="currentColor"
                      >
                        <path d="M5 3v4M3 5h4M6 17v4m-2-2h4m5-16l2.286 6.857L21 12l-5.714 2.143L13 21l-2.286-6.857L5 12l5.714-2.143L13 3z">
                        </path>
                      </svg>
                      <span class="flex-1 w-0 ml-2 truncate">
                        Update your draft queue
                      </span>
                    </div>
                    <div class="flex-shrink-0 ml-4">
                      <.link
                        href={~p"/fantasy_teams/#{@fantasy_team.id}/draft_queues/edit"}
                        class="font-medium text-indigo-600 hover:text-indigo-500 transition duration-150 ease-in-out"
                      >
                        Manage
                      </.link>
                    </div>
                  </li>
                </ul>
              </dd>
            </div>
          <% end %>
        </dl>
      </div>
    </div>

    <div class="flex flex-row flex-wrap justify-between">
      <div class="min-w-full sm:min-w-0">
        <.section_header>
          Roster
        </.section_header>
        <.roster_positions_table fantasy_team={@fantasy_team} />

        <.section_header>
          Multi-Event Sports
        </.section_header>

        <.champ_with_events_table fantasy_team={@fantasy_team} />
        <.champ_slots_table fantasy_team={@fantasy_team} />
      </div>

      <div>
        <%= if (owner?(@current_user, @fantasy_team) || admin?(@current_user)) do %>
          <.section_header>
            Draft Queues (<%= FantasyTeams.display_autodraft_setting(@fantasy_team) %>)
          </.section_header>
          <.draft_queue_table fantasy_team={@fantasy_team} />
        <% end %>
      </div>

      <div class="flex flex-col min-w-full align-items-stretch">
        <.section_header>
          Future Draft Picks
        </.section_header>
        <.future_picks_table fantasy_team={@fantasy_team} />
      </div>
    </div>
    """
  end
end
