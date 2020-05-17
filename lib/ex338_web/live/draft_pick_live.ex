defmodule Ex338Web.DraftPickLive do
  @moduledoc false
  use Ex338Web, :live_view

  alias Ex338.{DraftPick, FantasyLeague, User}
  alias Ex338Web.DraftPickView

  def mount(_params, session, socket) do
    if connected?(socket), do: DraftPick.Store.subscribe()
    %{"fantasy_league_id" => fantasy_league_id, "current_user_id" => current_user_id} = session

    %{draft_picks: picks, fantasy_teams: teams} =
      DraftPick.Store.get_picks_for_league(fantasy_league_id)

    sports_league_id = ""

    filtered_draft_picks = filter_draft_picks_by_sport(picks, sports_league_id)

    socket =
      socket
      |> assign(:fantasy_teams, teams)
      |> assign(:draft_picks, picks)
      |> assign(:sports_league_id, sports_league_id)
      |> assign(:filtered_draft_picks, filtered_draft_picks)
      |> assign_new(:current_user, fn -> User.Store.get_user!(current_user_id) end)
      |> assign_new(:fantasy_league, fn -> FantasyLeague.Store.get(fantasy_league_id) end)
      |> assign_new(:sports_league_options, fn -> sports_league_options(picks) end)

    # need to clear flash from controller so not displayed twice
    socket = clear_flash(socket)

    {:ok, socket}
  end

  def render(assigns) do
    DraftPickView.render("tables.html", assigns)
  end

  def handle_info({"draft_pick", [:draft_pick | _], _}, socket) do
    new_data = DraftPick.Store.get_picks_for_league(socket.assigns.fantasy_league.id)

    filtered_draft_picks =
      filter_draft_picks_by_sport(new_data.draft_picks, socket.assigns.sports_league_id)

    socket =
      socket
      |> assign(new_data)
      |> assign(filtered_draft_picks: filtered_draft_picks)
      |> put_flash(:info, "New pick!")

    {:noreply, assign(socket, new_data)}
  end

  def handle_event("filter", %{"sports_league_id" => sport_id}, socket) do
    picks = filter_draft_picks_by_sport(socket.assigns.draft_picks, sport_id)
    socket = assign(socket, sports_league_id: sport_id, filtered_draft_picks: picks)
    {:noreply, socket}
  end

  ## Helpers

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

  defp sports_league_options(draft_picks) do
    options =
      draft_picks
      |> Enum.reduce([], fn
        %{fantasy_player: %{sports_league: sports_league}}, options ->
          [{sports_league.abbrev, sports_league.id}] ++ options

        _, options ->
          options
      end)
      |> Enum.uniq()
      |> Enum.sort_by(fn {abbrev, _} -> abbrev end)

    [{"All Sports", ""}] ++ options
  end
end
