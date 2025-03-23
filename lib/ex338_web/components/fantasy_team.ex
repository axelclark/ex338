defmodule Ex338Web.FantasyTeamComponents do
  @moduledoc """
  Provides fantasy team UI components.
  """
  use Phoenix.Component

  use Phoenix.VerifiedRoutes,
    endpoint: Ex338Web.Endpoint,
    router: Ex338Web.Router

  import Ex338.RosterPositions.Admin,
    only: [primary_positions: 1, flex_and_unassigned_positions: 1]

  import Ex338Web.CoreComponents
  import Ex338Web.HTMLHelpers

  alias Ex338.DraftQueues.DraftQueue
  alias Ex338.FantasyLeagues.FantasyLeague
  alias Ex338.RosterPositions.RosterPosition

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
        {@roster_position.position}
      </.legacy_td>

      <.legacy_td>
        {if @roster_position.fantasy_player, do: @roster_position.fantasy_player.player_name}
      </.legacy_td>

      <.legacy_td>
        <div class="flex items-center">
          {if @roster_position.fantasy_player,
            do: @roster_position.fantasy_player.sports_league.abbrev}
          <div class="pl-1 h-4 w-4">
            {deadline_icon_for_position(@roster_position)}
          </div>
        </div>
      </.legacy_td>

      <.legacy_td class={
        if(display_points(@roster_position) == 0, do: "text-gray-300 text-center") || " text-center"
      }>
        {display_points(@roster_position)}
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
                      {result.championship.title}
                    </td>
                    <td class="px-2 sm:px-6 py-2 whitespace-normal border-b border-gray-200 text-sm text-center leading-5 text-gray-500">
                    </td>
                    <td class="px-2 sm:px-6 py-2 whitespace-no-wrap border-b border-gray-200 text-sm text-center leading-5 text-gray-500">
                      {result.rank}
                    </td>
                    <td class="pl-2 pr-4 sm:px-6 py-2 whitespace-no-wrap border-b border-gray-200 text-sm text-center leading-5 text-gray-500">
                      {result.points}
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
                      {result.sport_abbrev}
                    </td>
                    <td class="px-2 sm:px-6 py-2 whitespace-normal border-b border-gray-200 text-sm text-center leading-5 text-gray-500">
                      {result.slot}
                    </td>
                    <td class="px-2 sm:px-6 py-2 whitespace-no-wrap border-b border-gray-200 text-sm text-center leading-5 text-gray-500">
                      {result.rank}
                    </td>
                    <td class="pl-2 pr-4 sm:px-6 py-2 whitespace-no-wrap border-b border-gray-200 text-sm text-center leading-5 text-gray-500">
                      {result.points}
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
                      {queue.order}
                    </td>
                    <td class="px-2 sm:px-6 py-2 whitespace-normal border-b border-gray-200 text-sm text-left leading-5 text-gray-500">
                      {queue.fantasy_player.player_name}
                    </td>
                    <td class="pl-2 pr-4 sm:px-6 py-2 whitespace-no-wrap border-b border-gray-200 text-sm text-left leading-5 text-gray-500">
                      {queue.fantasy_player.sports_league.abbrev}
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
              href={~p"/fantasy_teams/#{@fantasy_team.id}/draft_queues/edit"}
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
                      {pick.round}
                    </td>
                    <%= if pick.original_team_id !== @fantasy_team.id do %>
                      <td class="pl-2 pr-8 sm:px-6 py-2 whitespace-no-wrap border-b border-gray-200 text-sm text-left leading-5 text-indigo-700">
                        <.fantasy_team_name_link fantasy_team={pick.original_team} />
                      </td>
                    <% else %>
                      <td class="pl-2 pr-8 sm:px-6 py-2 whitespace-no-wrap border-b border-gray-200 text-sm text-left leading-5 text-gray-500">
                        {"--"}
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

  def deadline_icon_for_position(%{
        fantasy_player: %{sports_league: %{championships: [championship]}}
      }) do
    transaction_deadline_icon(championship)
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
