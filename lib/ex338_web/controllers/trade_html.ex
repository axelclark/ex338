defmodule Ex338Web.TradeHTML do
  use Ex338Web, :html

  alias Ex338.Trades.Trade

  def new(assigns) do
    ~H"""
    <.two_col_form :let={f} for={@changeset} action={~p"/fantasy_teams/#{@fantasy_team.id}/trades"}>
      <:title>
        Propose a new Trade from {@fantasy_team.team_name}
      </:title>
      <:description>
        Select players and/or future picks for proposed trade.  Select
        either a fantasy player or future pick for each line item.  You can't
        select both in a single line item.
      </:description>
      <.inputs_for :let={l} field={f[:trade_line_items]}>
        <.input
          field={l[:losing_team_id]}
          label="Losing Team"
          type="select"
          class="losing-team"
          options={format_teams_for_select(@league_teams)}
          prompt="Select the team losing the player"
        />

        <.input
          field={l[:fantasy_player_id]}
          label="Player for Trade"
          type="select"
          options={format_players_for_select(@league_players)}
          class="players-for-trade"
          prompt="Select the player to trade"
        />

        <.input
          field={l[:future_pick_id]}
          label="Future Pick for Trade"
          type="select"
          options={format_future_picks_for_select(@league_future_picks)}
          class="picks-for-trade"
          prompt="Select the future pick to trade"
        />

        <.input
          field={l[:gaining_team_id]}
          label="Gaining Team"
          type="select"
          options={format_teams_for_select(@league_teams)}
          prompt="Select the team gaining the player"
        />

        <div class="py-4 col-span-6">
          <div class="border-t border-gray-300"></div>
        </div>
      </.inputs_for>
      <.input field={f[:additional_terms]} label="Additional Terms" type="textarea" />
      <:actions>
        <.submit_buttons back_route={~p"/fantasy_teams/#{@fantasy_team}"} />
      </:actions>
    </.two_col_form>
    """
  end

  def index(assigns) do
    ~H"""
    <.page_header>
      Trades
    </.page_header>

    <.section_header>
      Proposed Trades
    </.section_header>

    <.trade_table
      current_user={@current_user}
      fantasy_league={@fantasy_league}
      trades={Enum.filter(@trades, &proposed_for_team?(&1, @current_user))}
    />

    <.section_header>
      Pending League Approval
    </.section_header>

    <.trade_table
      current_user={@current_user}
      fantasy_league={@fantasy_league}
      trades={Enum.filter(@trades, &(&1.status == "Pending"))}
    />

    <.section_header>
      Completed Trades
    </.section_header>

    <.trade_table
      current_user={@current_user}
      fantasy_league={@fantasy_league}
      trades={Enum.filter(@trades, &(&1.status == "Approved" || &1.status == "Disapproved"))}
    />
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
            Status
          </.legacy_th>
          <.legacy_th>
            Vote
          </.legacy_th>
        </tr>
      </thead>
      <tbody class="bg-white">
        <%= if @trades == [] do %>
          <tr>
            <.legacy_td>
              --
            </.legacy_td>
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
                {trade.status}
                <%= if proposed_for_team?(trade, @current_user) do %>
                  <.link
                    href={
                      ~p"/fantasy_teams/#{trade.submitted_by_team.id}/trades/#{trade.id}?#{%{"trade" => %{"status" => "Canceled"}}}"
                    }
                    data-confirm="Please confirm to cancel trade"
                    method="patch"
                    class="mt-1 inline-flex items-center px-2.5 py-1.5 border border-gray-300 text-xs leading-4 font-medium rounded text-red-700 bg-white hover:text-gray-500 focus:outline-none focus:border-blue-300 focus:shadow-outline-blue active:text-gray-800 active:bg-gray-50 transition ease-in-out duration-150"
                  >
                    Cancel
                  </.link>
                <% end %>
                <%= if admin?(@current_user) do %>
                  <%= if trade.status == "Pending" do %>
                    <div class="mt-1">
                      <.link
                        href={
                          ~p"/fantasy_teams/#{trade.submitted_by_team.id}/trades/#{trade.id}?#{%{"trade" => %{"status" => "Approved"}}}"
                        }
                        data-confirm="Please confirm to approve trade"
                        method="patch"
                        class="mt-1 inline-flex items-center px-2.5 py-1.5 border border-gray-300 text-xs leading-4 font-medium rounded text-gray-700 bg-white hover:text-gray-500 focus:outline-none focus:border-blue-300 focus:shadow-outline-blue active:text-gray-800 active:bg-gray-50 transition ease-in-out duration-150"
                      >
                        Approve
                      </.link>
                      <.link
                        href={
                          ~p"/fantasy_teams/#{trade.submitted_by_team.id}/trades/#{trade.id}?#{%{"trade" => %{"status" => "Disapproved"}}}"
                        }
                        data-confirm="Please confirm to disapprove trade"
                        method="patch"
                        class="mt-1 inline-flex items-center px-2.5 py-1.5 border border-gray-300 text-xs leading-4 font-medium rounded text-gray-700 bg-white hover:text-gray-500 focus:outline-none focus:border-blue-300 focus:shadow-outline-blue active:text-gray-800 active:bg-gray-50 transition ease-in-out duration-150"
                      >
                        Disapprove
                      </.link>
                    </div>
                  <% end %>
                <% end %>
              </.legacy_td>

              <.legacy_td class="align-top">
                <div x-data="{open: false}" @click.away="open = false">
                  <button @click="open = !open" class="focus:outline-none">
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
                        <div class="bg-white rounded-md shadow-xs">
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
                  <button @click="open = !open" class="focus:outline-none">
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
                        <div class="bg-white rounded-md shadow-xs">
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

                <%= if allow_vote?(trade, @current_user, @fantasy_league) do %>
                  <.link
                    href={
                      ~p"/fantasy_teams/#{get_team_for_league(@current_user.fantasy_teams, @fantasy_league)}/trade_votes?#{%{"trade_vote" => %{"approve" => "true", "trade_id" => trade.id}}}"
                    }
                    data-confirm="Please confirm vote"
                    method="post"
                    class="mt-1 sm:ml-1 inline-flex items-center px-2.5 py-1.5 border border-transparent text-xs leading-4 font-medium rounded text-indigo-700 bg-indigo-100 hover:bg-indigo-50 focus:outline-none focus:border-indigo-300 focus:shadow-outline-indigo active:bg-indigo-200 transition ease-in-out duration-150"
                  >
                    Yes
                  </.link>
                  <.link
                    href={
                      ~p"/fantasy_teams/#{get_team_for_league(@current_user.fantasy_teams, @fantasy_league)}/trade_votes?#{%{"trade_vote" => %{"approve" => "false", "trade_id" => trade.id}}}"
                    }
                    data-confirm="Please confirm vote"
                    method="post"
                    class="mt-1 sm:ml-1 inline-flex items-center px-2.5 py-1.5 border border-transparent text-xs leading-4 font-medium rounded text-indigo-700 bg-indigo-100 hover:bg-indigo-50 focus:outline-none focus:border-indigo-300 focus:shadow-outline-indigo active:bg-indigo-200 transition ease-in-out duration-150"
                  >
                    No
                  </.link>
                <% end %>
              </.legacy_td>
            </tr>
          <% end %>
        <% end %>
      </tbody>
    </.legacy_table>
    """
  end

  def allow_vote?(
        %{status: "Pending", trade_votes: votes},
        %{fantasy_teams: teams},
        fantasy_league
      ) do
    do_allow_vote?(votes, teams, fantasy_league)
  end

  def allow_vote?(
        %{status: "Proposed", trade_votes: votes},
        %{fantasy_teams: teams},
        fantasy_league
      ) do
    do_allow_vote?(votes, teams, fantasy_league)
  end

  def allow_vote?(_trade, _current_user, _fantasy_league), do: false

  def get_team_for_league([], _fantasy_league), do: :no_team

  def get_team_for_league(teams, fantasy_league) do
    case Enum.filter(teams, &(&1.fantasy_league_id == fantasy_league.id)) do
      [team] -> team
      [] -> :no_team
      _other -> raise "User owns two teams in league"
    end
  end

  def proposed_for_team?(%{status: "Proposed"}, %{admin: true}), do: true

  def proposed_for_team?(%{status: "Proposed"} = trade, %{fantasy_teams: teams}) do
    Enum.any?(teams, fn team ->
      trade
      |> Trade.get_teams_from_trade()
      |> match_any_team?(team)
    end)
  end

  def proposed_for_team?(_trade, _current_user), do: false

  ## Helpers

  # allow_vote?

  defp do_allow_vote?(votes, teams, fantasy_league) do
    case get_team_for_league(teams, fantasy_league) do
      :no_team -> false
      team -> team_has_not_voted?(votes, team)
    end
  end

  def team_has_not_voted?(votes, team) do
    !Enum.any?(votes, &(&1.fantasy_team_id == team.id))
  end

  # proposed_for_team

  defp match_any_team?(teams, team) do
    Enum.any?(teams, &(&1.id == team.id))
  end
end
