defmodule Ex338Web.ChampionshipLive.Index do
  @moduledoc false
  use Ex338Web, :live_view

  alias Ex338.Championships
  alias Ex338.FantasyLeagues

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"fantasy_league_id" => fantasy_league_id}, _, socket) do
    socket =
      socket
      |> assign(:championships, Championships.all_for_league(fantasy_league_id))
      |> assign(:fantasy_league, FantasyLeagues.get(fantasy_league_id))

    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.page_header class="sm:mb-6">
      {@fantasy_league.year} Championships
    </.page_header>

    <.championship_table
      championships={filter_category(@championships, "overall")}
      fantasy_league={@fantasy_league}
    />

    <.section_header>
      Championship Events
    </.section_header>

    <.championship_table
      championships={filter_category(@championships, "event")}
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
                {championship.title}
              </.link>
            </.legacy_td>
            <.legacy_td class="hidden sm:table-cell">
              <div class="flex">
                <div>
                  {championship.sports_league.abbrev}
                </div>

                <%= if transaction_deadline_icon(championship) != "" do %>
                  <div class="w-4 h-4 ml-1">
                    {transaction_deadline_icon(championship)}
                  </div>
                <% end %>
              </div>
            </.legacy_td>
            <.legacy_td>
              {short_datetime_pst(championship.waiver_deadline_at)}
            </.legacy_td>
            <.legacy_td>
              {short_datetime_pst(championship.trade_deadline_at)}
            </.legacy_td>
            <.legacy_td>
              {short_date_pst(championship.championship_at)}
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

  defp filter_category(championships, category) do
    Enum.filter(championships, &(&1.category == category))
  end
end
