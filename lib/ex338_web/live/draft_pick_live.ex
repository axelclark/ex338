defmodule Ex338Web.DraftPickLive do
  @moduledoc false
  use Phoenix.LiveView

  alias Ex338.DraftPick
  alias Ex338Web.DraftPickView

  def mount(session, socket) do
    DraftPick.Store.subscribe()

    data = %{
      current_user: session.current_user,
      draft_picks: session.draft_picks,
      fantasy_league: session.fantasy_league,
      fantasy_teams: session.fantasy_teams
    }

    {:ok, assign(socket, data)}
  end

  def render(assigns) do
    DraftPickView.render("tables.html", assigns)
  end

  def handle_info({"draft_pick", [:draft_pick | _], _}, socket) do
    new_data = DraftPick.Store.get_picks_for_league(socket.assigns.fantasy_league.id)

    {:noreply, assign(socket, new_data)}
  end
end
