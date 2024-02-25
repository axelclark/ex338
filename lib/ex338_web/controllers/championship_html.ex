defmodule Ex338Web.ChampionshipHTML do
  use Ex338Web, :html

  def index(assigns) do
    ~H"""
    <.page_header class="sm:mb-6">
      <%= @fantasy_league.year %> Championships
    </.page_header>

    <.championship_table
      championships={filter_category(@championships, "overall")}
      conn={@conn}
      fantasy_league={@fantasy_league}
    />

    <.section_header>
      Championship Events
    </.section_header>

    <.championship_table
      championships={filter_category(@championships, "event")}
      conn={@conn}
      fantasy_league={@fantasy_league}
    />
    """
  end

  defp championship_table(assigns) do
    ~H"""
    <.legacy_table class="lg:max-w-4xl">
      <thead>
        <tr>
          <.legacy_th>
            Title
          </.legacy_th>
          <.legacy_th class="hidden sm:table-cell">
            Sports League
          </.legacy_th>
          <.legacy_th>
            Waiver Deadline*
          </.legacy_th>
          <.legacy_th>
            Trade Deadline*
          </.legacy_th>
          <.legacy_th>
            Date
          </.legacy_th>
        </tr>
      </thead>
      <tbody class="bg-white">
        <%= for championship <- @championships do %>
          <tr>
            <.legacy_td class="text-indigo-700" style="word-break: break-word;">
              <.link href={
                ~p"/fantasy_leagues/#{@fantasy_league.id}/championships/#{championship.id}"
              }>
                <%= championship.title %>
              </.link>
            </.legacy_td>
            <.legacy_td class="hidden sm:table-cell">
              <div class="flex">
                <div>
                  <%= championship.sports_league.abbrev %>
                </div>

                <%= if transaction_deadline_icon(championship) != "" do %>
                  <div class="w-4 h-4 ml-1">
                    <%= transaction_deadline_icon(championship) %>
                  </div>
                <% end %>
              </div>
            </.legacy_td>
            <.legacy_td>
              <%= short_datetime_pst(championship.waiver_deadline_at) %>
            </.legacy_td>
            <.legacy_td>
              <%= short_datetime_pst(championship.trade_deadline_at) %>
            </.legacy_td>
            <.legacy_td>
              <%= short_date_pst(championship.championship_at) %>
            </.legacy_td>
          </tr>
        <% end %>
      </tbody>
    </.legacy_table>
    <p class="pl-4 mt-1 text-sm font-medium text-gray-500 leading-5 sm:mt-2 sm:pl-6">
      * All dates and times are in Pacific Standard Time (PST)/Pacific Daylight Time (PDT).
    </p>
    """
  end

  def show(assigns) do
    ~H"""
    <div class="overflow-hidden bg-white shadow sm:rounded-lg">
      <div class="px-4 py-5 border-b border-gray-200 sm:px-6">
        <div class="flex flex-wrap items-center justify-between -mt-2 -ml-4 sm:flex-no-wrap">
          <div class="mt-2 ml-4">
            <h3 class="text-lg font-medium text-gray-900 leading-6">
              <div class="flex items-center">
                <div class="ml-1">
                  <%= @championship.title %>
                </div>
                <%= if transaction_deadline_icon(@championship) != "" do %>
                  <div class="w-4 h-4 ml-1">
                    <%= transaction_deadline_icon(@championship) %>
                  </div>
                <% end %>
              </div>
            </h3>
          </div>
          <%= if show_create_slots(@current_user, @championship) do %>
            <div class="flex-shrink-0 mt-2 ml-4">
              <.link
                href={
                  ~p"/fantasy_leagues/#{@fantasy_league.id}/championship_slot_admin?#{%{championship_id: @championship.id}}"
                }
                class="bg-transparent hover:bg-indigo-500 text-indigo-600 text-sm font-medium hover:text-white py-2 px-4 border border-indigo-600 hover:border-transparent rounded"
                method="post"
                data-confirm="Please confirm to create roster slots"
              >
                Create Roster Slots
              </.link>
            </div>
          <% end %>

          <%= if show_create_picks(@current_user, @championship) do %>
            <div class="flex-shrink-0 mt-2 ml-4">
              <.link
                href={
                  ~p"/fantasy_leagues/#{@fantasy_league.id}/in_season_draft_order?#{%{championship_id: @championship.id}}"
                }
                class="bg-transparent hover:bg-indigo-500 text-indigo-600 text-sm font-medium hover:text-white py-2 px-4 border border-indigo-600 hover:border-transparent rounded"
                method="post"
                data-confirm="Please confirm to create draft picks"
              >
                Create Draft Picks
              </.link>
            </div>
          <% end %>
        </div>
      </div>
      <div class="px-4 py-5 sm:p-0">
        <dl>
          <div class="sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6 sm:py-5">
            <dt class="text-sm font-medium text-gray-500 leading-5">
              SportsLeague
            </dt>
            <dd class="mt-1 text-sm text-gray-900 leading-5 sm:mt-0 sm:col-span-2">
              <%= @championship.sports_league.league_name %>
            </dd>
          </div>
          <div class="mt-8 sm:mt-0 sm:grid sm:grid-cols-3 sm:gap-4 sm:border-t sm:border-gray-200 sm:px-6 sm:py-5">
            <dt class="text-sm font-medium text-gray-500 leading-5">
              Waiver Deadline
            </dt>
            <dd class="mt-1 text-sm text-gray-900 leading-5 sm:mt-0 sm:col-span-2">
              <%= short_datetime_pst(@championship.waiver_deadline_at) %>
            </dd>
          </div>
          <div class="mt-8 sm:mt-0 sm:grid sm:grid-cols-3 sm:gap-4 sm:border-t sm:border-gray-200 sm:px-6 sm:py-5">
            <dt class="text-sm font-medium text-gray-500 leading-5">
              Trade Deadline
            </dt>
            <dd class="mt-1 text-sm text-gray-900 leading-5 sm:mt-0 sm:col-span-2">
              <%= short_datetime_pst(@championship.trade_deadline_at) %>
            </dd>
          </div>
          <%= if @championship.draft_starts_at do %>
            <div class="mt-8 sm:mt-0 sm:grid sm:grid-cols-3 sm:gap-4 sm:border-t sm:border-gray-200 sm:px-6 sm:py-5">
              <dt class="text-sm font-medium text-gray-500 leading-5">
                Draft Starts At
              </dt>
              <dd class="mt-1 text-sm text-gray-900 leading-5 sm:mt-0 sm:col-span-2">
                <%= short_datetime_pst(@championship.draft_starts_at) %>
              </dd>
            </div>
            <div class="mt-8 sm:mt-0 sm:grid sm:grid-cols-3 sm:gap-4 sm:border-t sm:border-gray-200 sm:px-6 sm:py-5">
              <dt class="text-sm font-medium text-gray-500 leading-5">
                Time Limit For Each Pick
              </dt>
              <dd class="mt-1 text-sm text-gray-900 leading-5 sm:mt-0 sm:col-span-2">
                <%= @championship.max_draft_mins %> Minutes
              </dd>
            </div>
          <% end %>
          <div class="mt-8 sm:mt-0 sm:grid sm:grid-cols-3 sm:gap-4 sm:border-t sm:border-gray-200 sm:px-6 sm:py-5">
            <dt class="text-sm font-medium text-gray-500 leading-5">
              Championship Date
            </dt>
            <dd class="mt-1 text-sm text-gray-900 leading-5 sm:mt-0 sm:col-span-2">
              <%= short_date_pst(@championship.championship_at) %>
            </dd>
          </div>
          <div class="mt-8 sm:mt-0 sm:grid sm:grid-cols-3 sm:gap-4 sm:border-t sm:border-gray-200 sm:px-6 sm:py-5">
            <dt class="text-sm font-medium text-gray-500 leading-5">
              Timezones
            </dt>
            <dd class="mt-1 text-sm text-gray-900 leading-5 sm:mt-0 sm:col-span-2">
              All dates and times are in Pacific Standard Time (PST)/Pacific Daylight Time (PDT).
            </dd>
          </div>
        </dl>
      </div>
    </div>

    <div class="grid grid-cols-1 gap-4 lg:grid-cols-2">
      <%= if @championship.events == [] do %>
        <div class="col-span-2">
          <.section_header>
            <%= @championship.title %> Results
          </.section_header>

          <.results_table championship={@championship} />
        </div>
      <% else %>
        <div class="col-span-1">
          <.section_header>
            <%= @championship.title %> Results
          </.section_header>

          <.final_results_table championship={@championship} />
        </div>

        <div class="col-span-1">
          <.section_header>
            <%= @championship.title %> Overall Standings
          </.section_header>

          <.slots_standings championship={@championship} />
        </div>
      <% end %>

      <%= if @championship.championship_slots !== [] do %>
        <div class="col-span-1">
          <.section_header>
            <%= @championship.title %> Roster Slots
          </.section_header>

          <.slots_table conn={@conn} current_user={@current_user} championship={@championship} />
        </div>
      <% end %>

      <%= for event <- @championship.events do %>
        <div class="col-span-1">
          <.section_header>
            <%= event.title %> Results
          </.section_header>

          <.results_table championship={event} />
        </div>

        <%= if event.championship_slots !== [] do %>
          <div class="col-span-1">
            <.section_header>
              <%= event.title %> Roster Slots
            </.section_header>

            <.slots_table conn={@conn} current_user={@current_user} championship={event} />
          </div>
        <% end %>
      <% end %>

      <%= if @championship.in_season_draft do %>
        <div class="col-span-2">
          <.section_header>
            <%= @championship.title %> Draft
          </.section_header>

          <%= live_render(
            @conn,
            Ex338Web.ChampionshipLive,
            session: %{
              "current_user_id" => maybe_fetch_current_user_id(@current_user),
              "championship_id" => @championship.id,
              "fantasy_league_id" => @fantasy_league.id
            }
          ) %>
        </div>
      <% end %>
    </div>
    """
  end

  defp results_table(assigns) do
    ~H"""
    <.legacy_table class="md:max-w-3xl">
      <thead>
        <tr>
          <.legacy_th>
            Rank
          </.legacy_th>
          <.legacy_th>
            Points
          </.legacy_th>
          <.legacy_th>
            Fantasy Player
          </.legacy_th>
          <.legacy_th>
            Owner
          </.legacy_th>
        </tr>
      </thead>
      <tbody class="bg-white">
        <%= for result <- @championship.championship_results do %>
          <tr>
            <.legacy_td>
              <%= result.rank %>
            </.legacy_td>
            <.legacy_td>
              <%= result.points %>
            </.legacy_td>
            <.legacy_td>
              <%= result.fantasy_player.player_name %>
            </.legacy_td>
            <.legacy_td>
              <%= get_team_name(result) %>
            </.legacy_td>
          </tr>
        <% end %>
      </tbody>
    </.legacy_table>
    """
  end

  defp final_results_table(assigns) do
    ~H"""
    <.legacy_table class="md:max-w-2xl">
      <thead>
        <tr>
          <.legacy_th>
            Rank
          </.legacy_th>
          <.legacy_th>
            Points
          </.legacy_th>
          <.legacy_th>
            Fantasy Team
          </.legacy_th>
        </tr>
      </thead>
      <tbody class="bg-white">
        <%= for result <- @championship.champ_with_events_results do %>
          <tr>
            <.legacy_td>
              <%= result.rank %>
            </.legacy_td>
            <.legacy_td>
              <%= result.points %>
            </.legacy_td>
            <.legacy_td>
              <%= result.fantasy_team.team_name %>
            </.legacy_td>
          </tr>
        <% end %>
      </tbody>
    </.legacy_table>
    """
  end

  defp slots_standings(assigns) do
    ~H"""
    <.legacy_table class="md:max-w-2xl">
      <thead>
        <tr>
          <.legacy_th>
            Rank
          </.legacy_th>
          <.legacy_th>
            Fantasy Team
          </.legacy_th>
          <.legacy_th>
            Slot
          </.legacy_th>
          <.legacy_th>
            Points
          </.legacy_th>
        </tr>
      </thead>
      <tbody class="bg-white">
        <%= for slot <- @championship.slot_standings do %>
          <tr>
            <.legacy_td>
              <%= slot.rank %>
            </.legacy_td>
            <.legacy_td>
              <%= slot.team_name %>
            </.legacy_td>
            <.legacy_td>
              <%= slot.slot %>
            </.legacy_td>
            <.legacy_td>
              <%= slot.points %>
            </.legacy_td>
          </tr>
        <% end %>
      </tbody>
    </.legacy_table>
    """
  end

  defp slots_table(assigns) do
    ~H"""
    <.legacy_table class="md:max-w-2xl">
      <thead>
        <tr>
          <.legacy_th>
            Fantasy Team
          </.legacy_th>
          <.legacy_th>
            Slot
          </.legacy_th>
          <.legacy_th>
            Fantasy Player
          </.legacy_th>
          <%= if admin?(@current_user) do %>
            <.legacy_th>
              Action
            </.legacy_th>
          <% end %>
        </tr>
      </thead>
      <tbody class="bg-white">
        <%= for slot <- @championship.championship_slots do %>
          <tr>
            <.legacy_td>
              <%= slot.roster_position.fantasy_team.team_name %>
            </.legacy_td>
            <.legacy_td>
              <%= slot.slot %>
            </.legacy_td>
            <.legacy_td>
              <%= slot.roster_position.fantasy_player.player_name %>
            </.legacy_td>
            <%= if admin?(@current_user) do %>
              <.legacy_td>
                <.link
                  href={~p"/admin/#{"championships"}/#{"championship_slot"}/#{slot.id}"}
                  class="font-medium text-indigo-600 hover:text-indigo-500 transition duration-150 ease-in-out"
                >
                  Edit
                </.link>
              </.legacy_td>
            <% end %>
          </tr>
        <% end %>
      </tbody>
    </.legacy_table>
    """
  end

  def get_team_name(%{fantasy_player: %{roster_positions: [position]}}) do
    position.fantasy_team.team_name
  end

  def get_team_name(_) do
    "-"
  end

  def filter_category(championships, category) do
    Enum.filter(championships, &(&1.category == category))
  end

  def show_create_slots(%{admin: true}, %{category: "event", championship_slots: []}) do
    true
  end

  def show_create_slots(_user, _championship) do
    false
  end

  def show_create_picks(%{admin: true}, %{in_season_draft: true, in_season_draft_picks: []}) do
    true
  end

  def show_create_picks(_user, _championship) do
    false
  end

  def display_drafted_at_or_pick_due_at(%{available_to_pick?: false, drafted_player_id: nil}) do
    "---"
  end

  def display_drafted_at_or_pick_due_at(
        %{available_to_pick?: true, drafted_player_id: nil} = assigns
      ) do
    if assigns.over_time? do
      ~H"""
      <div class="text-red-600">
        <%= short_time_secs_pst(assigns.pick_due_at) %>*
      </div>
      """
    else
      ~H"""
      <div class="text-gray-800">
        <%= short_time_secs_pst(assigns.pick_due_at) %>*
      </div>
      """
    end
  end

  def display_drafted_at_or_pick_due_at(%{drafted_at: nil}) do
    "---"
  end

  def display_drafted_at_or_pick_due_at(pick) do
    short_time_pst(pick.drafted_at)
  end
end
