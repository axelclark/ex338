defmodule Ex338Web.DraftPickLive do
  @moduledoc false
  use Ex338Web, :live_view

  alias Ex338.{DraftPicks, FantasyLeagues, Accounts}
  alias Ex338Web.DraftPickView

  def mount(_params, session, socket) do
    if connected?(socket) do
      DraftPicks.subscribe()
      schedule_refresh()
    end

    %{"fantasy_league_id" => fantasy_league_id, "current_user_id" => current_user_id} = session

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
      |> assign_new(:current_user, fn -> maybe_update_current_user(current_user_id) end)
      |> assign_new(:fantasy_league, fn -> FantasyLeagues.get(fantasy_league_id) end)
      |> assign_new(:sports_league_options, fn -> sports_league_options(picks) end)
      |> assign_new(:fantasy_team_options, fn -> fantasy_team_options(picks) end)

    # need to clear flash from controller so not displayed twice
    socket = clear_flash(socket)

    {:ok, socket}
  end

  def render(assigns) do
    DraftPickView.render("tables.html", assigns)
  end

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

  def handle_event(
        "filter",
        %{"sports_league_id" => sport_id, "fantasy_team_id" => team_id},
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

  defp schedule_refresh(), do: Process.send_after(self(), :refresh, 1000 * 60)

  ## mount

  defp maybe_update_current_user(nil), do: nil

  defp maybe_update_current_user(current_user_id) do
    Accounts.get_user!(current_user_id)
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
          [{sports_league.abbrev, sports_league.id}] ++ options

        _, options ->
          options
      end)
      |> Enum.uniq()
      |> Enum.sort_by(fn {abbrev, _} -> abbrev end)

    [{"All Sports", ""}] ++ options
  end
end
