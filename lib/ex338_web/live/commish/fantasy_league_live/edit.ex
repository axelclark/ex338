defmodule Ex338Web.Commish.FantasyLeagueLive.Edit do
  @moduledoc false
  use Ex338Web, :live_view

  alias Ex338.FantasyLeagues

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    fantasy_league = FantasyLeagues.get_fantasy_league!(id)

    socket =
      socket
      |> assign(:page_title, "Edit Fantasy League")
      |> assign(:fantasy_league, fantasy_league)
      |> assign(
        :current_route,
        Routes.commish_fantasy_league_edit_path(socket, :edit, fantasy_league)
      )

    {:noreply, socket}
  end
end
