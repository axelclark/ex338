defmodule Ex338Web.Commish.FantasyLeagueLive.Edit do
  use Ex338Web, :live_view

  alias Ex338.FantasyLeagues

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    socket =
      socket
      |> assign(:page_title, "Edit Fantasy League")
      |> assign(:fantasy_league, FantasyLeagues.get_fantasy_league!(id))

    {:noreply, socket}
  end
end
