defmodule Ex338Web.ChampionshipLive do
  @moduledoc false
  use Phoenix.LiveView

  alias Ex338Web.ChampionshipView
  alias Ex338.{Championship, InSeasonDraftPick}

  def mount(session, socket) do
    InSeasonDraftPick.Store.subscribe()

    data = %{
      championship: session.championship,
      current_user: session.current_user,
      fantasy_league: session.fantasy_league
    }

    {:ok, assign(socket, data)}
  end

  def render(assigns) do
    ChampionshipView.render("draft_table.html", assigns)
  end

  def handle_info({"in_season_draft_pick", [:in_season_draft_pick | _], _}, socket) do
    championship =
      Championship.Store.get_championship_by_league(
        socket.assigns.championship.id,
        socket.assigns.fantasy_league.id
      )

    {:noreply, assign(socket, :championship, championship)}
  end
end
