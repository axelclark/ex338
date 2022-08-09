defmodule Ex338Web.ChampionshipLive do
  @moduledoc false
  use Ex338Web, :live_view

  alias Ex338.{Championships, FantasyLeagues, InSeasonDraftPicks, Accounts}
  alias Ex338Web.ChampionshipView

  def mount(_params, session, socket) do
    if connected?(socket) do
      InSeasonDraftPicks.subscribe()
      schedule_refresh()
    end

    %{
      "championship_id" => championship_id,
      "fantasy_league_id" => fantasy_league_id,
      "current_user_id" => current_user_id
    } = session

    socket =
      socket
      |> assign_new(:championship, fn ->
        Championships.get_championship_by_league(
          championship_id,
          fantasy_league_id
        )
      end)
      |> assign_new(:current_user, fn -> maybe_update_current_user(current_user_id) end)
      |> assign_new(:fantasy_league, fn -> FantasyLeagues.get(fantasy_league_id) end)

    # need to clear flash from controller so not displayed twice
    socket = clear_flash(socket)

    {:ok, socket}
  end

  def render(assigns) do
    ChampionshipView.render("draft_table.html", assigns)
  end

  def handle_info(:refresh, socket) do
    championship = Championships.update_next_in_season_pick(socket.assigns.championship)

    socket =
      socket
      |> assign(:championship, championship)

    schedule_refresh()

    {:noreply, socket}
  end

  def handle_info(
        {"in_season_draft_pick", [:in_season_draft_pick | _], in_season_draft_pick},
        socket
      ) do
    fantasy_league_id = socket.assigns.fantasy_league.id

    championship =
      Championships.get_championship_by_league(
        socket.assigns.championship.id,
        socket.assigns.fantasy_league.id
      )

    socket =
      socket
      |> maybe_put_flash(in_season_draft_pick, fantasy_league_id)
      |> assign(:championship, championship)

    {:noreply, socket}
  end

  # Implementations

  defp schedule_refresh() do
    one_second = 1000
    Process.send_after(self(), :refresh, one_second)
  end

  defp maybe_update_current_user(nil), do: nil

  defp maybe_update_current_user(current_user_id) do
    Accounts.get_user!(current_user_id)
  end

  ## handle_info in_season_draft_pick

  defp maybe_put_flash(socket, %{fantasy_league_id: league_id}, league_id) do
    put_flash(
      socket,
      :info,
      "New pick!"
    )
  end

  defp maybe_put_flash(socket, _, _), do: socket
end
