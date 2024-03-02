defmodule Ex338Web.FantasyTeamHTML do
  use Ex338Web, :html

  import Ex338.RosterPositions.Admin,
    only: [primary_positions: 1, flex_and_unassigned_positions: 1]

  alias Ex338.DraftQueues.DraftQueue
  alias Ex338.FantasyLeagues.FantasyLeague
  alias Ex338.FantasyTeams
  alias Ex338.FantasyTeams.FantasyTeam
  alias Ex338.RosterPositions.RosterPosition

  def index(assigns) do
    ~H"""
    <.page_header>
      Fantasy Teams
    </.page_header>

    <section>
      <div class="flex flex-row flex-wrap justify-between">
        <%= for team <- Enum.filter(@fantasy_teams, &owner?(@current_user, &1)) do %>
          <.team_card fantasy_team={team} />
        <% end %>
        <%= for team <- Enum.reject(@fantasy_teams, &owner?(@current_user, &1)) do %>
          <.team_card fantasy_team={team} />
        <% end %>
      </div>
    </section>
    """
  end

  attr :fantasy_team, :map, required: true

  def team_card(assigns) do
    ~H"""
    <div class="mb-6 w-screen sm:w-auto">
      <h2 class="pl-4 sm:pl-6 py-2 text-lg text-indigo-700">
        <.fantasy_team_name_link fantasy_team={@fantasy_team} />
      </h2>

      <.roster_positions_table fantasy_team={@fantasy_team} />

      <h3 class="pl-4 sm:pl-6 py-2 text-base text-gray-700">
        Multi-Event Sports
      </h3>

      <.champ_with_events_table fantasy_team={@fantasy_team} />
      <.champ_slots_table fantasy_team={@fantasy_team} />
    </div>
    """
  end

  attr :fantasy_team, :map, required: true

  def roster_positions_table(assigns) do
    ~H"""
    <.legacy_table>
      <thead>
        <tr>
          <.legacy_th>
            Position
          </.legacy_th>
          <.legacy_th>
            Player
          </.legacy_th>
          <.legacy_th>
            Sport
          </.legacy_th>
          <.legacy_th class="text-center">
            Points
          </.legacy_th>
        </tr>
      </thead>
      <tbody class="bg-white">
        <%= for roster_position <- sort_by_position(primary_positions(@fantasy_team.roster_positions)) do %>
          <.roster_positions_row roster_position={roster_position} />
        <% end %>

        <%= for roster_position <- sort_by_position(flex_and_unassigned_positions(@fantasy_team.roster_positions)) do %>
          <.roster_positions_row roster_position={roster_position} />
        <% end %>

        <%= for ir_position <- @fantasy_team.ir_positions do %>
          <.roster_positions_row roster_position={ir_position} />
        <% end %>
      </tbody>
    </.legacy_table>
    """
  end

  attr :roster_position, :map, required: true

  def roster_positions_row(assigns) do
    ~H"""
    <tr>
      <.legacy_td>
        <%= @roster_position.position %>
      </.legacy_td>

      <.legacy_td>
        <%= if @roster_position.fantasy_player, do: @roster_position.fantasy_player.player_name %>
      </.legacy_td>

      <.legacy_td>
        <div class="flex items-center">
          <%= if @roster_position.fantasy_player,
            do: @roster_position.fantasy_player.sports_league.abbrev %>
          <div class="pl-1 h-4 w-4">
            <%= deadline_icon_for_position(@roster_position) %>
          </div>
        </div>
      </.legacy_td>

      <.legacy_td class={
        if(display_points(@roster_position) == 0, do: "text-gray-300 text-center") || " text-center"
      }>
        <%= display_points(@roster_position) %>
      </.legacy_td>
    </tr>
    """
  end

  attr :fantasy_team, :map, required: true

  def champ_with_events_table(assigns) do
    ~H"""
    <div class="pb-6 md:max-w-md">
      <div class="-my-2 py-2 overflow-visible sm:-mx-6 sm:px-6 lg:-mx-8 lg:px-8">
        <div class="align-middle inline-block min-w-full shadow overflow-hidden sm:rounded-lg border-b border-gray-200">
          <table class="min-w-full">
            <thead>
              <tr>
                <th class="pl-4 pr-2 sm:px-6 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase tracking-wider">
                  Sport
                </th>
                <th class="px-2 sm:px-6 py-3 border-b border-gray-200 bg-gray-50 text-center text-xs leading-4 font-medium text-gray-500 uppercase tracking-wider">
                </th>
                <th class="px-2 sm:px-6 py-3 border-b border-gray-200 bg-gray-50 text-center text-xs leading-4 font-medium text-gray-500 uppercase tracking-wider">
                  Final Rank
                </th>
                <th class="pl-2 pr-4 sm:px-6 py-3 border-b border-gray-200 bg-gray-50 text-center text-xs leading-4 font-medium text-gray-500 uppercase tracking-wider">
                  Points
                </th>
              </tr>
            </thead>
            <tbody class="bg-white">
              <%= if @fantasy_team.champ_with_events_results == []do %>
                <td class="pl-4 pr-2 sm:px-6 py-2 whitespace-normal border-b border-gray-200 text-sm text-left leading-5 text-gray-500">
                  ---
                </td>
                <td class="px-2 sm:px-6 py-2 whitespace-normal border-b border-gray-200 text-sm text-center leading-5 text-gray-500">
                </td>
                <td class="px-2 sm:px-6 py-2 whitespace-normal border-b border-gray-200 text-sm text-center leading-5 text-gray-500">
                </td>
                <td class="pl-2 pr-4 sm:px-6 py-2 whitespace-no-wrap border-b border-gray-200 text-sm text-center leading-5 text-gray-500">
                </td>
              <% else %>
                <%= for result <- @fantasy_team.champ_with_events_results do %>
                  <tr>
                    <td class="pl-4 pr-2 sm:px-6 py-2 whitespace-normal border-b border-gray-200 text-sm text-left leading-5 text-gray-500">
                      <%= result.championship.title %>
                    </td>
                    <td class="px-2 sm:px-6 py-2 whitespace-normal border-b border-gray-200 text-sm text-center leading-5 text-gray-500">
                    </td>
                    <td class="px-2 sm:px-6 py-2 whitespace-no-wrap border-b border-gray-200 text-sm text-center leading-5 text-gray-500">
                      <%= result.rank %>
                    </td>
                    <td class="pl-2 pr-4 sm:px-6 py-2 whitespace-no-wrap border-b border-gray-200 text-sm text-center leading-5 text-gray-500">
                      <%= result.points %>
                    </td>
                  </tr>
                <% end %>
              <% end %>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    """
  end

  attr :fantasy_team, :map, required: true

  def champ_slots_table(assigns) do
    ~H"""
    <div class="md:max-w-md">
      <div class="-my-2 py-2 overflow-visible sm:-mx-6 sm:px-6 lg:-mx-8 lg:px-8">
        <div class="align-middle inline-block min-w-full shadow overflow-hidden sm:rounded-lg border-b border-gray-200">
          <table class="min-w-full">
            <thead>
              <tr>
                <th class="pl-4 pr-2 sm:px-6 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase tracking-wider">
                  Sport
                </th>
                <th class="px-2 sm:px-6 py-3 border-b border-gray-200 bg-gray-50 text-center text-xs leading-4 font-medium text-gray-500 uppercase tracking-wider">
                  Slot
                </th>
                <th class="px-2 sm:px-6 py-3 border-b border-gray-200 bg-gray-50 text-center text-xs leading-4 font-medium text-gray-500 uppercase tracking-wider">
                  Current Rank
                </th>
                <th class="pl-2 pr-4 sm:px-6 py-3 border-b border-gray-200 bg-gray-50 text-center text-xs leading-4 font-medium text-gray-500 uppercase tracking-wider">
                  Points
                </th>
              </tr>
            </thead>
            <tbody class="bg-white">
              <%= if @fantasy_team.slot_results == []do %>
                <td class="pl-4 pr-2 sm:px-6 py-2 whitespace-normal border-b border-gray-200 text-sm text-left leading-5 text-gray-500">
                  ---
                </td>
                <td class="px-2 sm:px-6 py-2 whitespace-normal border-b border-gray-200 text-sm text-center leading-5 text-gray-500">
                </td>
                <td class="px-2 sm:px-6 py-2 whitespace-normal border-b border-gray-200 text-sm text-center leading-5 text-gray-500">
                </td>
                <td class="pl-2 pr-4 sm:px-6 py-2 whitespace-no-wrap border-b border-gray-200 text-sm text-center leading-5 text-gray-500">
                </td>
              <% else %>
                <%= for result <- @fantasy_team.slot_results do %>
                  <tr>
                    <td class="pl-4 pr-2 sm:px-6 py-2 whitespace-normal border-b border-gray-200 text-sm text-left leading-5 text-gray-500">
                      <%= result.sport_abbrev %>
                    </td>
                    <td class="px-2 sm:px-6 py-2 whitespace-normal border-b border-gray-200 text-sm text-center leading-5 text-gray-500">
                      <%= result.slot %>
                    </td>
                    <td class="px-2 sm:px-6 py-2 whitespace-no-wrap border-b border-gray-200 text-sm text-center leading-5 text-gray-500">
                      <%= result.rank %>
                    </td>
                    <td class="pl-2 pr-4 sm:px-6 py-2 whitespace-no-wrap border-b border-gray-200 text-sm text-center leading-5 text-gray-500">
                      <%= result.points %>
                    </td>
                  </tr>
                <% end %>
              <% end %>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    """
  end

  def show(assigns) do
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
                        Update team, roster and queue
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
                        Add to your draft queue
                      </span>
                    </div>
                    <div class="flex-shrink-0 ml-4">
                      <.link
                        href={~p"/fantasy_teams/#{@fantasy_team.id}/draft_queues/new"}
                        class="font-medium text-indigo-600 hover:text-indigo-500 transition duration-150 ease-in-out"
                      >
                        Add Player
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

  attr :fantasy_team, :map, required: true

  def draft_queue_table(assigns) do
    ~H"""
    <div class="mb-4 md:max-w-md">
      <div class="-my-2 py-2 overflow-visible sm:-mx-6 sm:px-6 lg:-mx-8 lg:px-8">
        <div class="align-middle inline-block min-w-full shadow overflow-hidden sm:rounded-lg border-b border-gray-200">
          <table class="min-w-full">
            <thead>
              <tr>
                <th class="pl-4 pr-2 sm:px-6 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase tracking-wider">
                  Order
                </th>
                <th class="px-2 sm:px-6 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase tracking-wider">
                  Fantasy Player
                </th>
                <th class="pl-2 pr-4 sm:px-6 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase tracking-wider">
                  Sports League
                </th>
              </tr>
            </thead>
            <tbody class="bg-white">
              <%= if @fantasy_team.draft_queues == []do %>
                <td class="pl-4 pr-2 sm:px-6 py-2 whitespace-normal border-b border-gray-200 text-sm text-left leading-5 text-gray-500">
                  ---
                </td>
                <td class="px-2 sm:px-6 py-2 whitespace-normal border-b border-gray-200 text-sm text-left leading-5 text-gray-500">
                </td>
                <td class="pl-2 pr-4 sm:px-6 py-2 whitespace-no-wrap border-b border-gray-200 text-sm text-left leading-5 text-gray-500">
                </td>
              <% else %>
                <%= for queue <- @fantasy_team.draft_queues do %>
                  <tr>
                    <td class="pl-4 pr-2 sm:px-6 py-2 whitespace-normal border-b border-gray-200 text-sm text-left leading-5 text-gray-500">
                      <%= queue.order %>
                    </td>
                    <td class="px-2 sm:px-6 py-2 whitespace-normal border-b border-gray-200 text-sm text-left leading-5 text-gray-500">
                      <%= queue.fantasy_player.player_name %>
                    </td>
                    <td class="pl-2 pr-4 sm:px-6 py-2 whitespace-no-wrap border-b border-gray-200 text-sm text-left leading-5 text-gray-500">
                      <%= queue.fantasy_player.sports_league.abbrev %>
                    </td>
                  </tr>
                <% end %>
              <% end %>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <div class="bg-white md:max-w-md shadow overflow-hidden sm:rounded-lg">
      <div class="px-4 py-5 border-b border-gray-200 sm:px-6">
        <div class="-ml-4 -mt-4 flex justify-between items-center flex-wrap sm:flex-no-wrap">
          <div class="ml-4 mt-4">
            <h3 class="text-base leading-6 text-gray-800">
              Draft Queue Info
            </h3>
            <p class="mt-1 max-w-2xl text-sm leading-5 text-gray-500">
              Setting up your draft queue
            </p>
          </div>
          <div class="ml-4 mt-4 flex-shrink-0">
            <.link
              href={~p"/fantasy_teams/#{@fantasy_team.id}/draft_queues/new"}
              class="bg-transparent hover:bg-indigo-500 text-indigo-600 text-sm font-medium hover:text-white py-2 px-4 border border-indigo-600 hover:border-transparent rounded"
            >
              Add Player
            </.link>
          </div>
        </div>
      </div>
      <div class="px-4 py-5 sm:px-6">
        <dl class="grid grid-cols-1 gap-x-4 gap-y-8 sm:grid-cols-2">
          <div class="sm:col-span-2">
            <dt class="text-sm leading-5 font-medium text-gray-500">
              Draft Queue Settings
            </dt>
            <dd class="mt-1 text-sm leading-5 text-gray-900">
              When your pick is up, the system will automatically make your pick from your draft queue.  If
              another team drafts a player in your draft queue before your turn, the player will be removed
              and your queue will be reordered. Make Pick & Pause will make a single pick from your draft
              queue and turn the draft queue setting to Off.
            </dd>
          </div>
          <div class="sm:col-span-2">
            <dt class="text-sm leading-5 font-medium text-gray-500">
              KD and LLWS Drafts
            </dt>
            <dd class="mt-1 text-sm leading-5 text-gray-900">
              For Kentucky Derby and LLWS, the horses/teams must be loaded into the system before you can
              build your queue.  Using the draft queue is optional, teams can still draft normally by not
              adding teams to their queue.
            </dd>
          </div>
        </dl>
      </div>
    </div>
    """
  end

  attr :fantasy_team, :map, required: true

  def future_picks_table(assigns) do
    ~H"""
    <div class="mb-10 md:max-w-md">
      <div class="-my-2 py-2 overflow-visible sm:-mx-6 sm:px-6 lg:-mx-8 lg:px-8">
        <div class="align-middle inline-block min-w-full shadow overflow-hidden sm:rounded-lg border-b border-gray-200">
          <table class="min-w-full">
            <thead>
              <tr>
                <th class="pl-8 pr-2 sm:px-6 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase tracking-wider">
                  Round
                </th>
                <th class="pl-2 pr-8 sm:px-6 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase tracking-wider">
                  Original Team
                </th>
              </tr>
            </thead>
            <tbody class="bg-white">
              <%= if @fantasy_team.future_picks == []do %>
                <td class="pl-8 pr-2 sm:px-6 py-2 whitespace-normal border-b border-gray-200 text-sm text-left leading-5 text-gray-500">
                  ---
                </td>
                <td class="pl-2 pr-8 sm:px-6 py-2 whitespace-no-wrap border-b border-gray-200 text-sm text-left leading-5 text-gray-500">
                </td>
              <% else %>
                <%= for pick <- Enum.sort_by(@fantasy_team.future_picks, & &1.round) do %>
                  <tr>
                    <td class="pl-8 pr-2 sm:px-6 py-2 whitespace-normal border-b border-gray-200 text-sm text-left leading-5 text-gray-500">
                      <%= pick.round %>
                    </td>
                    <%= if pick.original_team_id !== @fantasy_team.id do %>
                      <td class="pl-2 pr-8 sm:px-6 py-2 whitespace-no-wrap border-b border-gray-200 text-sm text-left leading-5 text-indigo-700">
                        <.fantasy_team_name_link fantasy_team={pick.original_team} />
                      </td>
                    <% else %>
                      <td class="pl-2 pr-8 sm:px-6 py-2 whitespace-no-wrap border-b border-gray-200 text-sm text-left leading-5 text-gray-500">
                        <%= "--" %>
                      </td>
                    <% end %>
                  </tr>
                <% end %>
              <% end %>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    """
  end

  def edit(assigns) do
    ~H"""
    <.form :let={f} for={@changeset} action={~p"/fantasy_teams/#{@fantasy_team}"}>
      <div class="mt-6">
        <div class="md:grid md:grid-cols-3 md:gap-6">
          <div class="md:col-span-1">
            <div class="px-4 sm:px-0">
              <h3 class="text-lg font-medium text-gray-900 leading-6">
                Update Team Info
              </h3>
              <p class="mt-1 text-sm text-gray-600 leading-5">
                Update team name and set autodraft settings for draft queue
              </p>
            </div>
          </div>
          <div class="mt-5 md:mt-0 md:col-span-2">
            <div class="shadow sm:rounded-md sm:overflow-hidden">
              <div class="px-4 py-5 bg-white sm:p-6">
                <div class="grid grid-cols-3 gap-6">
                  <.error :if={f.source.action} class="!mt-0 col-span-3">
                    Oops, something went wrong! Please check the errors below.
                  </.error>
                  <div class="col-span-3 sm:col-span-2 space-y-6">
                    <.input field={f[:team_name]} label="Team Name" type="text" />
                    <.input
                      field={f[:auto_draft_setting]}
                      label="Sports League"
                      type="select"
                      options={FantasyTeam.autodraft_setting_options()}
                    />
                  </div>
                </div>
              </div>

              <div class="flex flex-row justify-end px-4 py-3 sm:px-6 bg-gray-50 sm:justify-start">
                <.submit_buttons back_route={~p"/fantasy_teams/#{@fantasy_team.id}"} />
              </div>
            </div>
          </div>
        </div>
      </div>
      <div class="hidden sm:block">
        <div class="py-5">
          <div class="border-t border-gray-300"></div>
        </div>
      </div>
      <div class="mt-10 sm:mt-0">
        <div class="md:grid md:grid-cols-3 md:gap-6">
          <div class="md:col-span-1">
            <div class="px-4 sm:px-0">
              <h3 class="text-lg font-medium text-gray-900 leading-6">
                Roster Positions
              </h3>
              <p class="mt-1 text-sm text-gray-600 leading-5">
                Update roster positions for your team
              </p>
            </div>
          </div>
          <div class="mt-5 md:mt-0 md:col-span-2">
            <div class="overflow-hidden shadow sm:rounded-md">
              <div class="bg-white sm:p-6">
                <div class="flex justify-center">
                  <.roster_positions_form form={f} fantasy_team={@fantasy_team} />
                </div>
              </div>

              <div class="flex flex-row justify-end px-4 py-3 sm:px-6 bg-gray-50 sm:justify-start">
                <.submit_buttons back_route={~p"/fantasy_teams/#{@fantasy_team.id}"} />
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="hidden sm:block">
        <div class="py-5">
          <div class="border-t border-gray-300"></div>
        </div>
      </div>

      <div class="mt-10 sm:mt-0">
        <div class="md:grid md:grid-cols-3 md:gap-6">
          <div class="md:col-span-1">
            <div class="px-4 sm:px-0">
              <h3 class="text-lg font-medium text-gray-900 leading-6">
                Draft Queues
              </h3>
              <p class="mt-1 text-sm text-gray-600 leading-5">
                Reorder or delete draft queues for your team
              </p>
            </div>
          </div>
          <div class="mt-5 md:mt-0 md:col-span-2">
            <div class="overflow-hidden shadow sm:rounded-md">
              <div class="bg-white sm:p-6">
                <div class="flex justify-center">
                  <.draft_queue_form form={f} fantasy_team={@fantasy_team} />
                </div>
              </div>
              <div class="flex flex-row justify-end px-4 py-3 sm:px-6 bg-gray-50 sm:justify-start">
                <.submit_buttons back_route={~p"/fantasy_teams/#{@fantasy_team.id}"} />
              </div>
            </div>
          </div>
        </div>
      </div>
    </.form>
    """
  end

  attr :form, :map, required: true
  attr :fantasy_team, :map, required: true

  def roster_positions_form(assigns) do
    ~H"""
    <div class="min-w-full md:max-w-md">
      <div class="-my-2 py-2 overflow-visible sm:-mx-6 sm:px-6 lg:-mx-8 lg:px-8">
        <div class="align-middle inline-block min-w-full shadow overflow-hidden sm:rounded-lg border-b border-gray-200">
          <table class="min-w-full">
            <thead>
              <tr>
                <th class="pl-4 pr-2 sm:px-6 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase tracking-wider">
                  Position
                </th>
                <th class="px-2 sm:px-6 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase tracking-wider">
                  Player
                </th>
                <th class="pl-2 pr-4 sm:px-6 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase tracking-wider">
                  Sport
                </th>
              </tr>
            </thead>
            <tbody class="bg-white">
              <%= if @fantasy_team.roster_positions == []do %>
                <td class="pl-4 pr-2 sm:px-6 py-1 whitespace-normal border-b border-gray-200 text-sm text-left leading-5 text-gray-500">
                  ---
                </td>
                <td class="px-2 sm:px-6 py-2 whitespace-normal border-b border-gray-200 text-sm text-left leading-5 text-gray-500">
                </td>
                <td class="px-2 sm:px-6 py-2 whitespace-normal border-b border-gray-200 text-sm text-left leading-5 text-gray-500">
                </td>
                <td class="pl-2 pr-4 sm:px-6 py-2 whitespace-normal border-b border-gray-200 text-sm text-left leading-5 text-gray-500">
                </td>
              <% else %>
                <.inputs_for :let={r} field={@form[:roster_positions]}>
                  <tr>
                    <td class="pl-4 pr-2 sm:px-6 py-1 whitespace-normal border-b border-gray-200 text-sm text-left leading-5 text-gray-500">
                      <.input
                        field={r[:position]}
                        type="select"
                        options={position_selections(r, @fantasy_team.fantasy_league)}
                        class="!mt-0"
                      />
                    </td>
                    <td
                      class="px-2 sm:px-6 py-2 whitespace-normal break-words border-b border-gray-200 text-sm text-left leading-5 text-gray-500"
                      style="word-break: break-word;"
                    >
                      <%= if r.data.fantasy_player, do: r.data.fantasy_player.player_name %>
                    </td>
                    <td class="pl-2 pr-4 sm:px-6 py-2 whitespace-normal border-b border-gray-200 text-sm text-left leading-5 text-gray-500">
                      <div class="flex items-center">
                        <%= if r.data.fantasy_player, do: r.data.fantasy_player.sports_league.abbrev %>
                      </div>
                    </td>
                  </tr>
                </.inputs_for>
              <% end %>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    """
  end

  attr :form, :map, required: true
  attr :fantasy_team, :map, required: true

  def draft_queue_form(assigns) do
    ~H"""
    <div class="min-w-full md:max-w-md">
      <div class="-my-2 py-2 overflow-visible sm:-mx-6 sm:px-6 lg:-mx-8 lg:px-8">
        <div class="align-middle inline-block min-w-full shadow overflow-hidden sm:rounded-lg border-b border-gray-200">
          <table class="min-w-full">
            <thead>
              <tr>
                <th class="pl-4 pr-2 sm:px-6 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase tracking-wider">
                  Order
                </th>
                <th class="px-2 sm:px-6 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase tracking-wider">
                  Player
                </th>
                <th class="px-2 sm:px-6 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase tracking-wider">
                  Sport
                </th>
                <th class="pl-2 pr-4 sm:px-6 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase tracking-wider">
                  Status
                </th>
              </tr>
            </thead>
            <tbody class="bg-white">
              <%= if @fantasy_team.draft_queues == []do %>
                <td class="pl-4 pr-2 sm:px-6 py-2 whitespace-normal border-b border-gray-200 text-sm text-left leading-5 text-gray-500">
                  ---
                </td>
                <td class="px-2 sm:px-6 py-2 whitespace-normal border-b border-gray-200 text-sm text-left leading-5 text-gray-500">
                </td>
                <td class="px-2 sm:px-6 py-2 whitespace-normal border-b border-gray-200 text-sm text-left leading-5 text-gray-500">
                </td>
                <td class="pl-2 pr-4 sm:px-6 py-2 whitespace-no-wrap border-b border-gray-200 text-sm text-left leading-5 text-gray-500">
                </td>
              <% else %>
                <.inputs_for :let={q} field={@form[:draft_queues]}>
                  <tr>
                    <td class="pl-4 pr-2 sm:px-6 py-2 whitespace-normal border-b border-gray-200 text-sm text-left leading-5 text-gray-500">
                      <.input
                        field={q[:order]}
                        type="select"
                        options={order_range(@form)}
                        class="!mt-0"
                      />
                    </td>
                    <td class="px-2 sm:px-6 py-2 whitespace-normal border-b border-gray-200 text-sm text-left leading-5 text-gray-500">
                      <%= q.data.fantasy_player.player_name %>
                      <.fantasy_player_id_errors field={q[:fantasy_player_id]} />
                    </td>
                    <td class="px-2 sm:px-6 py-2 whitespace-normal border-b border-gray-200 text-sm text-left leading-5 text-gray-500">
                      <%= q.data.fantasy_player.sports_league.abbrev %>
                    </td>
                    <td class="pl-2 pr-4 sm:px-6 py-2 whitespace-no-wrap border-b border-gray-200 text-sm text-left leading-5 text-gray-500">
                      <.input
                        field={q[:status]}
                        type="select"
                        options={queue_status_options()}
                        class="!mt-0"
                      />
                    </td>
                  </tr>
                </.inputs_for>
              <% end %>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    """
  end

  attr :field, :map, required: true

  defp fantasy_player_id_errors(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: field.id)
    |> assign(:errors, Enum.map(field.errors, &translate_error(&1)))
    |> assign_new(:name, fn -> field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> fantasy_player_id_errors()
  end

  defp fantasy_player_id_errors(assigns) do
    ~H"""
    <div phx-feedback-for={@name}>
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  def deadline_icon_for_position(%{
        fantasy_player: %{sports_league: %{championships: [championship]}}
      }) do
    Ex338Web.ViewHelpers.transaction_deadline_icon(championship)
  end

  def deadline_icon_for_position(_), do: ""

  def display_points(
        %{fantasy_player: %{sports_league: %{championships: [%{season_ended?: season_ended?}]}}} =
          roster_position
      ) do
    roster_position.fantasy_player.championship_results
    |> List.first()
    |> display_value(season_ended?)
  end

  def display_points(_), do: ""

  def order_range(team_form_struct) do
    current_order_numbers = Enum.map(team_form_struct.data.draft_queues, & &1.order)

    number_of_queues = Enum.count(team_form_struct.data.draft_queues)

    count_of_queues =
      case number_of_queues do
        0 -> []
        total -> Enum.to_list(1..total)
      end

    all_order_numbers = count_of_queues ++ current_order_numbers

    all_order_numbers
    |> Enum.sort()
    |> Enum.uniq()
  end

  def position_selections(_, %FantasyLeague{only_flex?: true, max_flex_spots: num_spots}) do
    RosterPosition.flex_positions(num_spots)
  end

  def position_selections(position_form_struct, %FantasyLeague{max_flex_spots: num_spots}) do
    [position_form_struct.data.fantasy_player.sports_league.abbrev] ++
      RosterPosition.flex_positions(num_spots)
  end

  def queue_status_options do
    DraftQueue.owner_status_options()
  end

  def sort_by_position(query) do
    Enum.sort(query, &(&1.position <= &2.position))
  end

  ## Helpers

  ## display_points

  defp display_value(nil, false), do: ""
  defp display_value(nil, true), do: 0
  defp display_value(result, _), do: Map.get(result, :points)
end
