defmodule Ex338Web.DraftPickLive do
  @moduledoc false
  use Phoenix.LiveView

  alias Ex338.{DraftPick, FantasyLeague, User}
  alias Ex338Web.DraftPickView

  def mount(_params, session, socket) do
    if connected?(socket), do: DraftPick.Store.subscribe()
    %{"fantasy_league_id" => fantasy_league_id, "current_user_id" => current_user_id} = session

    %{draft_picks: picks, fantasy_teams: teams} =
      DraftPick.Store.get_picks_for_league(fantasy_league_id)

    socket =
      socket
      |> assign(:draft_picks, picks)
      |> assign(:fantasy_teams, teams)
      |> assign_new(:current_user, fn -> User.Store.get_user!(current_user_id) end)
      |> assign_new(:fantasy_league, fn -> FantasyLeague.Store.get(fantasy_league_id) end)

    {:ok, socket}
  end

  def render(assigns) do
    DraftPickView.render("tables.html", assigns)
  end

  def handle_info({"draft_pick", [:draft_pick | _], _}, socket) do
    new_data = DraftPick.Store.get_picks_for_league(socket.assigns.fantasy_league.id)

    {:noreply, assign(socket, new_data)}
  end
end
