defmodule Ex338Web.Components.Commish do
  @moduledoc """
  Provides commish UI components.
  """
  use Phoenix.Component
  use Phoenix.VerifiedRoutes, endpoint: Ex338Web.Endpoint, router: Ex338Web.Router

  import Ex338Web.CoreComponents
  import Ex338Web.HTMLHelpers

  attr :current_route, :string, required: true
  attr :fantasy_league, :map, required: true

  def tabs(assigns) do
    ~H"""
    <div class="border-b border-gray-300">
      <nav class="flex -mb-px">
        <.commish_tab_link
          current_route={@current_route}
          path={~p"/commish/fantasy_leagues/#{@fantasy_league}/approvals"}
        >
          Process Actions
        </.commish_tab_link>
        <.commish_tab_link
          current_route={@current_route}
          path={~p"/commish/fantasy_leagues/#{@fantasy_league}/edit"}
        >
          Edit League
        </.commish_tab_link>
      </nav>
    </div>
    """
  end

  attr :current_route, :string, required: true
  attr :path, :string, required: true
  slot :inner_block, required: true

  defp commish_tab_link(%{current_route: path, path: path} = assigns) do
    ~H"""
    <.link
      href={@path}
      class="px-1 py-4 first:ml-0 ml-8 text-sm font-medium text-indigo-600 whitespace-no-wrap border-b-2 border-indigo-500 leading-5 focus:outline-hidden focus:text-indigo-800 focus:border-indigo-700"
    >
      {render_slot(@inner_block)}
    </.link>
    """
  end

  defp commish_tab_link(assigns) do
    ~H"""
    <.link
      href={@path}
      class="px-1 py-4 first:ml-0 ml-8 text-sm font-medium text-gray-500 whitespace-no-wrap border-b-2 border-transparent leading-5 hover:text-gray-700 hover:border-gray-300 focus:outline-hidden focus:text-gray-700 focus:border-gray-300"
    >
      {render_slot(@inner_block)}
    </.link>
    """
  end

  attr :fantasy_league, :map, required: true

  def toggle(assigns) do
    ~H"""
    <span class="pl-4 text-sm text-gray-500 truncate sm:mt-1 sm:pl-6 leading-5">
      {@fantasy_league.fantasy_league_name}
    </span>
    <!-- On: "bg-indigo-600", Off: "bg-gray-200" -->
    <span
      role="checkbox"
      id="toggle-league-approval-filter"
      tabindex="0"
      aria-checked="false"
      phx-click="toggle_league_filter"
      x-data="{ on: false }"
      x-on:click="on = !on"
      x-bind:class="{ 'bg-gray-700': !on, 'bg-indigo-600': on }"
      class="relative inline-flex shrink-0 h-6 bg-gray-700 border-2 border-transparent rounded-full cursor-pointer w-11 transition-colors ease-in-out duration-200 focus:outline-hidden focus:shadow-outline"
    >
      <!-- On: "translate-x-5", Off: "translate-x-0" -->
      <span
        aria-hidden="true"
        x-bind:class="{'translate-x-5': on, 'translate-x-0': !on}"
        class="inline-block w-5 h-5 bg-white rounded-full shadow-sm translate-x-0 transform transition ease-in-out duration-200"
      >
      </span>
    </span>

    <span class="text-sm text-gray-500 truncate sm:mt-1 leading-5">
      Show All
    </span>
    """
  end

  attr :injured_reserves, :list, required: true
  attr :filter, :atom, required: true

  def injured_reserve_table(assigns) do
    ~H"""
    <div class="flex flex-col">
      <div class="py-2 -my-2 overflow-x-auto sm:-mx-6 sm:px-6 lg:-mx-8 lg:px-8">
        <div class="inline-block min-w-full overflow-hidden align-middle border-b border-gray-200 shadow-sm sm:rounded-lg">
          <table class="min-w-full">
            <thead>
              <tr>
                <.legacy_th>
                  Submitted*
                </.legacy_th>
                <.legacy_th>
                  Team
                </.legacy_th>
                <.legacy_th>
                  Injured Player
                </.legacy_th>
                <.legacy_th>
                  Replacement Player
                </.legacy_th>
                <.legacy_th>
                  Status
                </.legacy_th>
                <.legacy_th>
                  Actions
                </.legacy_th>
              </tr>
            </thead>
            <tbody class="bg-white">
              <%= if @injured_reserves == [] do %>
                <tr>
                  <.legacy_td>
                    None for review
                  </.legacy_td>
                  <.legacy_td></.legacy_td>
                  <.legacy_td></.legacy_td>
                  <.legacy_td></.legacy_td>
                  <.legacy_td></.legacy_td>
                  <.legacy_td></.legacy_td>
                </tr>
              <% else %>
                <%= for injured_reserve <- @injured_reserves do %>
                  <tr>
                    <.legacy_td>
                      {short_datetime_pst(injured_reserve.inserted_at)}
                    </.legacy_td>
                    <.legacy_td>
                      <.link href={~p"/fantasy_teams/#{injured_reserve.fantasy_team.id}"}>
                        {injured_reserve.fantasy_team.team_name}
                      </.link>

                      <%= if @filter == :all do %>
                        <div>
                          {injured_reserve.fantasy_team.fantasy_league.fantasy_league_name}
                        </div>
                      <% end %>
                    </.legacy_td>
                    <.legacy_td>
                      {injured_reserve.injured_player.player_name} ({injured_reserve.injured_player.sports_league.abbrev})
                    </.legacy_td>
                    <.legacy_td>
                      {injured_reserve.replacement_player.player_name} ({injured_reserve.replacement_player.sports_league.abbrev})
                    </.legacy_td>
                    <.legacy_td>
                      {injured_reserve.status}
                    </.legacy_td>
                    <.legacy_td>
                      <.injured_reserve_admin_buttons injured_reserve={injured_reserve} />
                    </.legacy_td>
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

  def trade_table(assigns) do
    ~H"""
    <.legacy_table class="lg:max-w-4xl">
      <thead>
        <tr>
          <.legacy_th>
            Date
          </.legacy_th>
          <.legacy_th>
            Trade
          </.legacy_th>
          <.legacy_th>
            Vote
          </.legacy_th>
          <.legacy_th>
            Status
          </.legacy_th>
          <.legacy_th>
            Actions
          </.legacy_th>
        </tr>
      </thead>
      <tbody class="bg-white">
        <%= if @trades == [] do %>
          <tr>
            <.legacy_td>
              None for review
            </.legacy_td>
            <.legacy_td></.legacy_td>
            <.legacy_td></.legacy_td>
            <.legacy_td></.legacy_td>
            <.legacy_td></.legacy_td>
          </tr>
        <% else %>
          <%= for trade <- @trades do %>
            <tr>
              <.legacy_td class="align-top">
                {short_date_pst(trade.inserted_at)}
              </.legacy_td>

              <.legacy_td class="align-top">
                <ul>
                  <%= if @filter == :all do %>
                    <li class="mt-1 first:mt-0">
                      {hd(trade.trade_line_items).gaining_team.fantasy_league.fantasy_league_name}
                    </li>
                  <% end %>
                  <%= for line_item <- trade.trade_line_items do %>
                    <li class="mt-1 first:mt-0">
                      {line_item.gaining_team.team_name <> " "} gets
                      <%= if(line_item.fantasy_player) do %>
                        {" " <> line_item.fantasy_player.player_name <> " "}
                      <% else %>
                        {display_future_pick(line_item.future_pick)}
                      <% end %>
                      from {" " <> line_item.losing_team.team_name}
                    </li>
                  <% end %>
                  <li class="mt-1 first:mt-0">
                    {if trade.additional_terms, do: trade.additional_terms}
                  </li>
                </ul>
              </.legacy_td>

              <.legacy_td class="align-top">
                <div x-data="{open: false}" @click.away="open = false">
                  <button @click="open = !open" class="focus:outline-hidden">
                    <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium leading-4 bg-green-100 text-green-800">
                      {trade.yes_votes}
                    </span>
                  </button>
                  <%= if Enum.any?(trade.trade_votes, &(&1.approve == true)) do %>
                    <div
                      x-show="open"
                      x-transition:enter="transition ease-out duration-100"
                      x-transition:enter-start="transform opacity-0 scale-95"
                      x-transition:enter-end="transform opacity-100 scale-100"
                      x-transition:leave="transition ease-in duration-75"
                      x-transition:leave-start="transform opacity-100 scale-100"
                      x-transition:leave-end="transform opacity-0 scale-95"
                      class="relative inline-block text-left"
                    >
                      <div class="absolute right-0 w-56 mt-2 shadow-lg origin-top-right rounded-md">
                        <div class="bg-white rounded-md shadow-2xs">
                          <div
                            class="py-1"
                            role="menu"
                            aria-orientation="vertical"
                            aria-labelledby="options-menu"
                          >
                            <ul>
                              <%= for vote <- trade.trade_votes, vote.approve do %>
                                <li class="block px-4 py-1 text-sm text-gray-700 leading-5">
                                  {vote.fantasy_team.team_name}
                                </li>
                              <% end %>
                            </ul>
                          </div>
                        </div>
                      </div>
                    </div>
                  <% end %>
                </div>

                <div x-data="{open: false}" @click.away="open = false">
                  <button @click="open = !open" class="focus:outline-hidden">
                    <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium leading-4 bg-red-100 text-red-800">
                      {trade.no_votes}
                    </span>
                  </button>
                  <%= if Enum.any?(trade.trade_votes, &(&1.approve == false)) do %>
                    <div
                      x-show="open"
                      x-transition:enter="transition ease-out duration-100"
                      x-transition:enter-start="transform opacity-0 scale-95"
                      x-transition:enter-end="transform opacity-100 scale-100"
                      x-transition:leave="transition ease-in duration-75"
                      x-transition:leave-start="transform opacity-100 scale-100"
                      x-transition:leave-end="transform opacity-0 scale-95"
                      class="relative inline-block text-left"
                    >
                      <div class="absolute right-0 w-56 mt-2 shadow-lg origin-top-right rounded-md">
                        <div class="bg-white rounded-md shadow-2xs">
                          <div
                            class="py-1"
                            role="menu"
                            aria-orientation="vertical"
                            aria-labelledby="options-menu"
                          >
                            <ul>
                              <%= for vote <- trade.trade_votes, !vote.approve do %>
                                <li class="block px-4 py-1 text-sm text-gray-700 leading-5">
                                  {vote.fantasy_team.team_name}
                                </li>
                              <% end %>
                            </ul>
                          </div>
                        </div>
                      </div>
                    </div>
                  <% end %>
                </div>
              </.legacy_td>

              <.legacy_td class="align-top">
                {trade.status}
              </.legacy_td>

              <.legacy_td class="align-top">
                <.trade_admin_buttons trade={trade} />
              </.legacy_td>
            </tr>
          <% end %>
        <% end %>
      </tbody>
    </.legacy_table>
    """
  end

  def trade_admin_buttons(assigns) do
    ~H"""
    <button
      id={"approve-trade-#{@trade.id}"}
      phx-click="update_trade"
      phx-value-id={@trade.id}
      phx-value-status="Approved"
      class="inline-flex items-center px-2.5 py-1.5 border border-gray-300 text-xs leading-4 font-medium rounded-sm text-indigo-700 bg-white hover:text-gray-500 focus:outline-hidden focus:border-blue-300 focus:shadow-outline-blue active:text-gray-800 active:bg-gray-50 transition ease-in-out duration-150"
    >
      Approve
    </button>
    <button
      id={"disapprove-trade-#{@trade.id}"}
      phx-click="update_trade"
      phx-value-id={@trade.id}
      phx-value-status="Disapproved"
      class="inline-flex items-center ml-1 mt-1 px-2.5 py-1.5 border border-gray-300 text-xs leading-4 font-medium rounded-sm text-red-700 bg-white hover:text-gray-500 focus:outline-hidden focus:border-blue-300 focus:shadow-outline-blue active:text-gray-800 active:bg-gray-50 transition ease-in-out duration-150"
    >
      Disapprove
    </button>
    """
  end

  def injured_reserve_admin_buttons(%{injured_reserve: %{status: :submitted}} = assigns) do
    ~H"""
    <button
      id={"approve-injured-reserve-#{@injured_reserve.id}"}
      phx-click="update_injured_reserve"
      phx-value-id={@injured_reserve.id}
      phx-value-status="approved"
      class="inline-flex items-center px-2.5 py-1.5 border border-gray-300 text-xs leading-4 font-medium rounded-sm text-indigo-700 bg-white hover:text-gray-500 focus:outline-hidden focus:border-blue-300 focus:shadow-outline-blue active:text-gray-800 active:bg-gray-50 transition ease-in-out duration-150"
    >
      Approve
    </button>
    <button
      id={"reject-injured-reserve-#{@injured_reserve.id}"}
      phx-click="update_injured_reserve"
      phx-value-id={@injured_reserve.id}
      phx-value-status="rejected"
      class="inline-flex items-center ml-1 mt-1 px-2.5 py-1.5 border border-gray-300 text-xs leading-4 font-medium rounded-sm text-red-700 bg-white hover:text-gray-500 focus:outline-hidden focus:border-blue-300 focus:shadow-outline-blue active:text-gray-800 active:bg-gray-50 transition ease-in-out duration-150"
    >
      Reject
    </button>
    """
  end

  def injured_reserve_admin_buttons(%{injured_reserve: %{status: :approved}} = assigns) do
    ~H"""
    <button
      id={"return-injured-reserve-#{@injured_reserve.id}"}
      phx-click="update_injured_reserve"
      phx-value-id={@injured_reserve.id}
      phx-value-status="returned"
      class="inline-flex items-center px-2.5 py-1.5 border border-gray-300 text-xs leading-4 font-medium rounded-sm text-indigo-700 bg-white hover:text-gray-500 focus:outline-hidden focus:border-blue-300 focus:shadow-outline-blue active:text-gray-800 active:bg-gray-50 transition ease-in-out duration-150"
    >
      Return
    </button>
    """
  end
end
