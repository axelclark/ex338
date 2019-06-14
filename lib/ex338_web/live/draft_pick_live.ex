defmodule Ex338Web.DraftPickLive do
  @moduledoc false
  use Phoenix.LiveView

  alias Ex338Web.DraftPickView
  alias Ex338.{DraftPick, FantasyLeague, User}

  def mount(session, socket) do
    DraftPick.Store.subscribe()

    %{draft_picks: picks, fantasy_teams: teams} =
      DraftPick.Store.get_picks_for_league(session.fantasy_league_id)

    data = %{
      current_user: User.Store.get_user!(session.current_user_id),
      draft_picks: picks,
      fantasy_league: FantasyLeague.Store.get(session.fantasy_league_id),
      fantasy_teams: teams
    }

    {:ok, assign(socket, data)}
  end

  def render(assigns) do
    DraftPickView.render("index.html", assigns)
  end

  def handle_info({"draft_pick", [:draft_pick | _], _}, socket) do
    new_data = DraftPick.Store.get_picks_for_league(socket.assigns.fantasy_league.id)

    {:noreply, assign(socket, new_data)}
  end
end
