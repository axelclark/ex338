defmodule Ex338Web.ChampionshipLive.Show do
  @moduledoc false

  use Ex338Web, :live_view

  alias Ex338.Championships
  alias Ex338.FantasyLeagues
  alias Ex338.InSeasonDraftPicks

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      InSeasonDraftPicks.subscribe()
      schedule_refresh()
    end

    {:ok, socket}
  end

  @impl true
  def handle_params(
        %{"fantasy_league_id" => fantasy_league_id, "championship_id" => championship_id},
        _,
        socket
      ) do
    socket =
      socket
      |> assign(
        :championship,
        Championships.get_championship_by_league(
          championship_id,
          fantasy_league_id
        )
      )
      |> assign(:fantasy_league, FantasyLeagues.get(fantasy_league_id))

    {:noreply, socket}
  end

  @impl true
  def handle_info(:refresh, socket) do
    championship = Championships.update_next_in_season_pick(socket.assigns.championship)

    socket =
      assign(socket, :championship, championship)

    schedule_refresh()

    {:noreply, socket}
  end

  def handle_info(
        {"in_season_draft_pick", [:in_season_draft_pick | _], in_season_draft_pick},
        socket
      ) do
    fantasy_league_id = socket.assigns.fantasy_league.id

    if in_season_draft_pick.fantasy_league_id == fantasy_league_id do
      championship =
        Championships.get_championship_by_league(
          socket.assigns.championship.id,
          socket.assigns.fantasy_league.id
        )

      socket =
        socket
        |> put_flash(:info, "New pick!")
        |> push_event("animate", %{id: "draft-pick-#{in_season_draft_pick.id}-player"})
        |> assign(:championship, championship)

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  # Implementations

  defp schedule_refresh do
    one_second = 1000
    Process.send_after(self(), :refresh, one_second)
  end

  def display_autodraft_setting(:single), do: "⚠️ Make Pick & Pause"
  def display_autodraft_setting(:on), do: "✅ On"
  def display_autodraft_setting(:off), do: "❌ Off"

  @impl true
  def render(assigns) do
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

          <.slots_table current_user={@current_user} championship={@championship} />
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

            <.slots_table current_user={@current_user} championship={event} />
          </div>
        <% end %>
      <% end %>

      <%= if @championship.in_season_draft do %>
        <div class="col-span-2">
          <.section_header>
            <%= @championship.title %> Draft
          </.section_header>
          <.inseason_draft_table
            championship={@championship}
            socket={@socket}
            current_user={@current_user}
          />
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

  def inseason_draft_table(assigns) do
    ~H"""
    <.legacy_table class="md:max-w-2xl">
      <thead>
        <tr>
          <.legacy_th>
            Order
          </.legacy_th>
          <.legacy_th>
            Drafted / Due*
          </.legacy_th>
          <.legacy_th>
            Fantasy Team
          </.legacy_th>
          <.legacy_th>
            Fantasy Player
          </.legacy_th>
        </tr>
      </thead>
      <tbody class="bg-white">
        <%= for pick <- @championship.in_season_draft_picks do %>
          <tr>
            <.legacy_td>
              <%= pick.position %>
            </.legacy_td>
            <.legacy_td>
              <%= display_drafted_at_or_pick_due_at(pick) %>
            </.legacy_td>
            <.legacy_td style="word-break: break-word;">
              <%= if pick.draft_pick_asset.fantasy_team do %>
                <%= fantasy_team_link(@socket, pick.draft_pick_asset.fantasy_team) %>
              <% end %>
              <%= if admin?(@current_user) do %>
                <%= " - " <>
                  display_autodraft_setting(pick.draft_pick_asset.fantasy_team.autodraft_setting) %>
              <% end %>
            </.legacy_td>
            <.legacy_td
              id={"draft-pick-#{pick.id}-player"}
              data-animate={animate_in("#draft-pick-#{pick.id}-player")}
            >
              <%= if pick.drafted_player do %>
                <%= pick.drafted_player.player_name %>
              <% else %>
                <%= if pick.available_to_pick? && (owner?(@current_user, pick) || admin?(@current_user)) do %>
                  <.link href={~p"/in_season_draft_picks/#{pick}/edit"} class="text-indigo-700">
                    Submit Pick
                  </.link>
                <% end %>
              <% end %>
            </.legacy_td>
          </tr>
        <% end %>
      </tbody>
    </.legacy_table>
    """
  end

  defp get_team_name(%{fantasy_player: %{roster_positions: [position]}}) do
    position.fantasy_team.team_name
  end

  defp get_team_name(_) do
    "-"
  end

  defp show_create_slots(%{admin: true}, %{category: "event", championship_slots: []}) do
    true
  end

  defp show_create_slots(_user, _championship) do
    false
  end

  defp show_create_picks(%{admin: true}, %{in_season_draft: true, in_season_draft_picks: []}) do
    true
  end

  defp show_create_picks(_user, _championship) do
    false
  end

  defp display_drafted_at_or_pick_due_at(%{available_to_pick?: false, drafted_player_id: nil}) do
    "---"
  end

  defp display_drafted_at_or_pick_due_at(
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

  defp display_drafted_at_or_pick_due_at(%{drafted_at: nil}) do
    "---"
  end

  defp display_drafted_at_or_pick_due_at(pick) do
    short_time_pst(pick.drafted_at)
  end

  def animate_in(element_id) do
    JS.add_class("animate-in slide-in-from-right duration-500", to: element_id)
  end
end
