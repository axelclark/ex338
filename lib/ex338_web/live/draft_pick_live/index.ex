defmodule Ex338Web.DraftPickLive.Index do
  @moduledoc false
  use Ex338Web, :live_view

  alias Ex338.DraftPicks
  alias Ex338.FantasyLeagues
  alias Ex338.FantasyTeams

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      DraftPicks.subscribe()
      schedule_refresh()
    end

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"fantasy_league_id" => fantasy_league_id}, _, socket) do
    %{draft_picks: picks, fantasy_teams: teams} =
      DraftPicks.get_picks_for_league(fantasy_league_id)

    filter_params = %{sports_league_id: "", fantasy_team_id: ""}

    filtered_draft_picks = filter_draft_picks(picks, filter_params)

    socket =
      socket
      |> assign(:fantasy_teams, teams)
      |> assign(:draft_picks, picks)
      |> assign(filter_params)
      |> assign(:filtered_draft_picks, filtered_draft_picks)
      |> assign(:fantasy_league, FantasyLeagues.get(fantasy_league_id))
      |> assign(:sports_league_options, sports_league_options(picks))
      |> assign(:fantasy_team_options, fantasy_team_options(picks))

    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.page_header>
      Draft Picks for Division <%= @fantasy_league.division %>
    </.page_header>

    <h3 class="py-2 pl-4 text-base text-gray-700 sm:pl-6">
      Latest Picks
    </h3>
    <.current_table current_user={@current_user} draft_picks={current_picks(@draft_picks, 10)} />

    <.section_header>
      Time On the Clock
    </.section_header>

    <.team_summary_table current_user={@current_user} fantasy_teams={@fantasy_teams} />

    <%= if @fantasy_league.max_draft_hours > 0 do %>
      <p class="pl-4 mt-1 text-sm font-medium text-gray-700 leading-5 sm:mt-2 sm:pl-6">
        The commish has set a max total time limit of <strong><%= @fantasy_league.max_draft_hours %> hours</strong>.  Once a team has exceeded the total hours, it can be skipped in the draft order. Teams over the total draft time limit can avoid getting skipped by using the draft queue.
      </p>
    <% end %>

    <.section_header>
      Draft Picks
    </.section_header>

    <.form :let={f} for={%{}} as={:filter} phx-change="filter">
      <div class="mt-1 mb-4 grid grid-cols-1 gap-y-2 gap-x-8 sm:grid-cols-6">
        <div class="sm:col-span-2">
          <label for="location" class="block ml-1 text-sm font-medium text-gray-700 sm:ml-0 leading-5">
            Filter by team
          </label>
          <.input
            field={f[:fantasy_team_id]}
            type="select"
            options={@fantasy_team_options}
            class="block w-full py-2 pl-3 pr-10 mt-1 text-base border-gray-300 form-select leading-6 focus:outline-none focus:shadow-outline-blue focus:border-blue-300 sm:text-sm sm:leading-5"
          />
        </div>

        <div class="sm:col-span-2">
          <label for="location" class="block ml-1 text-sm font-medium text-gray-700 sm:ml- leading-5">
            Filter by sport
          </label>
          <.input
            field={f[:sports_league_id]}
            type="select"
            options={@sports_league_options}
            class="block w-full py-2 pl-3 pr-10 mt-1 text-base border-gray-300 form-select leading-6 focus:outline-none focus:shadow-outline-blue focus:border-blue-300 sm:text-sm sm:leading-5"
          />
        </div>
      </div>
    </.form>

    <.draft_table current_user={@current_user} filtered_draft_picks={@filtered_draft_picks} />
    """
  end

  defp current_table(assigns) do
    ~H"""
    <.legacy_table class="lg:max-w-4xl">
      <thead>
        <tr>
          <.legacy_th class="hidden sm:table-cell">
            Overall Pick
          </.legacy_th>
          <.legacy_th>
            Draft Position
          </.legacy_th>
          <.legacy_th>
            Fantasy Team
          </.legacy_th>
          <.legacy_th>
            Fantasy Player
          </.legacy_th>
          <.legacy_th>
            Sports League
          </.legacy_th>
        </tr>
      </thead>
      <tbody class="bg-white">
        <%= for draft_pick <- @draft_picks do %>
          <tr>
            <.legacy_td class="hidden sm:table-cell">
              <%= draft_pick.pick_number %>
            </.legacy_td>
            <.legacy_td>
              <%= draft_pick.draft_position %>
            </.legacy_td>
            <.legacy_td style="word-break: break-word;">
              <%= if draft_pick.fantasy_team do %>
                <.fantasy_team_name_link fantasy_team={draft_pick.fantasy_team} />
              <% end %>
            </.legacy_td>
            <.legacy_td>
              <%= if draft_pick.fantasy_player do %>
                <%= draft_pick.fantasy_player.player_name %>
              <% else %>
                <%= if draft_pick.available_to_pick? && (owner?(@current_user, draft_pick) || admin?(@current_user)) do %>
                  <.link href={~p"/draft_picks/#{draft_pick}/edit"} class="text-indigo-700">
                    Submit Pick
                  </.link>
                <% end %>
              <% end %>
            </.legacy_td>
            <.legacy_td>
              <%= if draft_pick.fantasy_player do %>
                <%= draft_pick.fantasy_player.sports_league.abbrev %>
              <% end %>
            </.legacy_td>
          </tr>
        <% end %>
      </tbody>
    </.legacy_table>
    """
  end

  defp team_summary_table(assigns) do
    ~H"""
    <.legacy_table class="lg:max-w-4xl">
      <thead>
        <tr>
          <.legacy_th>
            Fantasy Team
          </.legacy_th>
          <.legacy_th class="text-center">
            Number of Picks
          </.legacy_th>
          <.legacy_th class="text-right">
            Avg Mins On the Clock
          </.legacy_th>
          <.legacy_th class="text-right">
            Total Hours On the Clock
          </.legacy_th>
        </tr>
      </thead>
      <tbody class="bg-white">
        <%= for team <- @fantasy_teams do %>
          <tr>
            <.legacy_td style="word-break: break-word;">
              <.fantasy_team_name_link fantasy_team={team} />
              <%= if admin?(@current_user) do %>
                <%= " - " <> FantasyTeams.display_autodraft_setting(team) %>
              <% end %>
            </.legacy_td>
            <.legacy_td class="text-center">
              <%= team.picks_selected %>
            </.legacy_td>
            <.legacy_td class="text-right">
              <%= seconds_to_mins(team.avg_seconds_on_the_clock) %>
            </.legacy_td>
            <.legacy_td class="text-right">
              <%= seconds_to_hours(team.total_seconds_on_the_clock) %>
            </.legacy_td>
          </tr>
        <% end %>
      </tbody>
    </.legacy_table>
    """
  end

  defp draft_table(assigns) do
    ~H"""
    <.legacy_table class="lg:max-w-4xl table draft-picks-table">
      <thead>
        <tr>
          <.legacy_th class="hidden sm:table-cell">
            Overall Pick
          </.legacy_th>
          <.legacy_th>
            Draft Position
          </.legacy_th>
          <.legacy_th>
            Fantasy Team
          </.legacy_th>
          <.legacy_th>
            Fantasy Player
          </.legacy_th>
          <.legacy_th>
            Sports League
          </.legacy_th>
        </tr>
      </thead>
      <tbody class="bg-white">
        <%= for draft_pick <- @filtered_draft_picks do %>
          <tr>
            <.legacy_td class="hidden sm:table-cell">
              <%= draft_pick.pick_number %>
            </.legacy_td>
            <.legacy_td>
              <%= draft_pick.draft_position %>
            </.legacy_td>
            <.legacy_td style="word-break: break-word;">
              <%= if draft_pick.fantasy_team do %>
                <.fantasy_team_name_link fantasy_team={draft_pick.fantasy_team} />
              <% end %>
            </.legacy_td>
            <.legacy_td>
              <%= if draft_pick.fantasy_player do %>
                <%= draft_pick.fantasy_player.player_name %>
              <% else %>
                <%= if draft_pick.available_to_pick? && (owner?(@current_user, draft_pick) || admin?(@current_user)) do %>
                  <.link href={~p"/draft_picks/#{draft_pick}/edit"} class="text-indigo-700">
                    Submit Pick
                  </.link>
                <% end %>
              <% end %>
            </.legacy_td>
            <.legacy_td>
              <%= if draft_pick.fantasy_player do %>
                <%= draft_pick.fantasy_player.sports_league.abbrev %>
              <% end %>
            </.legacy_td>
          </tr>
        <% end %>
      </tbody>
    </.legacy_table>
    """
  end

  @impl true
  def handle_info(:refresh, socket) do
    new_data = DraftPicks.get_picks_for_league(socket.assigns.fantasy_league.id)

    filtered_draft_picks = filter_draft_picks(new_data.draft_picks, socket.assigns)

    socket =
      socket
      |> assign(new_data)
      |> assign(filtered_draft_picks: filtered_draft_picks)

    schedule_refresh()

    {:noreply, socket}
  end

  def handle_info({"draft_pick", [:draft_pick | _], draft_pick}, socket) do
    fantasy_league_id = socket.assigns.fantasy_league.id
    new_data = DraftPicks.get_picks_for_league(fantasy_league_id)
    filtered_draft_picks = filter_draft_picks(new_data.draft_picks, socket.assigns)

    socket =
      socket
      |> assign(new_data)
      |> assign(filtered_draft_picks: filtered_draft_picks)
      |> maybe_put_flash(draft_pick, fantasy_league_id)

    {:noreply, socket}
  end

  defp maybe_put_flash(socket, %{fantasy_league_id: league_id} = draft_pick, league_id) do
    put_flash(
      socket,
      :info,
      "#{draft_pick.fantasy_team.team_name} selected #{draft_pick.fantasy_player.player_name}!"
    )
  end

  defp maybe_put_flash(socket, _, _), do: socket

  @impl true
  def handle_event(
        "filter",
        %{"filter" => %{"sports_league_id" => sport_id, "fantasy_team_id" => team_id}},
        socket
      ) do
    draft_picks = socket.assigns.draft_picks
    filter_params = %{sports_league_id: sport_id, fantasy_team_id: team_id}

    filtered_draft_picks = filter_draft_picks(draft_picks, filter_params)

    socket =
      socket
      |> assign(filtered_draft_picks: filtered_draft_picks)
      |> assign(filter_params)

    {:noreply, socket}
  end

  ## Helpers

  def filter_draft_picks(draft_picks, %{
        fantasy_team_id: fantasy_team_id,
        sports_league_id: sports_league_id
      }) do
    draft_picks
    |> filter_draft_picks_by_sport(sports_league_id)
    |> filter_draft_picks_by_team(fantasy_team_id)
  end

  defp filter_draft_picks_by_sport(draft_picks, ""), do: draft_picks

  defp filter_draft_picks_by_sport(draft_picks, sports_league_id) do
    sports_league_id = String.to_integer(sports_league_id)

    Enum.filter(draft_picks, fn
      %{fantasy_player: %{sports_league: sports_league}} ->
        sports_league.id == sports_league_id

      _ ->
        false
    end)
  end

  defp filter_draft_picks_by_team(draft_picks, ""), do: draft_picks

  defp filter_draft_picks_by_team(draft_picks, fantasy_team_id) do
    fantasy_team_id = String.to_integer(fantasy_team_id)

    Enum.filter(draft_picks, fn
      %{fantasy_team: fantasy_team} ->
        fantasy_team.id == fantasy_team_id

      _ ->
        false
    end)
  end

  defp schedule_refresh, do: Process.send_after(self(), :refresh, 1000 * 60)

  defp current_picks(draft_picks, amount) when amount >= 0 do
    next_pick_index = Enum.find_index(draft_picks, &(&1.fantasy_player_id == nil))
    get_current_picks(draft_picks, next_pick_index, amount)
  end

  defp get_current_picks(draft_picks, nil, amount) do
    Enum.take(draft_picks, -div(amount, 2))
  end

  defp get_current_picks(draft_picks, index, amount) do
    start_index = index - div(amount, 2)

    start_index =
      if start_index < 0 do
        0
      else
        start_index
      end

    Enum.slice(draft_picks, start_index, amount)
  end

  defp seconds_to_hours(seconds) do
    Float.floor(seconds / 3600, 2)
  end

  defp seconds_to_mins(seconds) do
    Float.floor(seconds / 60, 2)
  end

  defp fantasy_team_options(draft_picks) do
    options =
      draft_picks
      |> Enum.reduce([], fn
        %{fantasy_team: fantasy_team}, options ->
          [{fantasy_team.team_name, fantasy_team.id}] ++ options

        _, options ->
          options
      end)
      |> Enum.uniq()
      |> Enum.sort_by(fn {team_name, _} -> team_name end)

    [{"All Teams", ""}] ++ options
  end

  defp sports_league_options(draft_picks) do
    options =
      draft_picks
      |> Enum.reduce([], fn
        %{fantasy_player: %{sports_league: sports_league}}, options ->
          [{sports_league.league_name, sports_league.id}] ++ options

        _, options ->
          options
      end)
      |> Enum.uniq()
      |> Enum.sort_by(fn {league_name, _} -> league_name end)

    [{"All Sports", ""}] ++ options
  end
end
