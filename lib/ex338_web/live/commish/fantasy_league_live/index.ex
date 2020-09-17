defmodule Ex338Web.Commish.FantasyLeagueLive.Index do
  use Ex338Web, :live_view

  alias Ex338.FantasyLeagues
  alias Ex338.FantasyLeagues.FantasyLeague

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :fantasy_leagues, list_fantasy_leagues())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Fantasy league")
    |> assign(:fantasy_league, FantasyLeagues.get_fantasy_league!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Fantasy league")
    |> assign(:fantasy_league, %FantasyLeague{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Fantasy leagues")
    |> assign(:fantasy_league, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    fantasy_league = FantasyLeagues.get_fantasy_league!(id)
    {:ok, _} = FantasyLeagues.delete_fantasy_league(fantasy_league)

    {:noreply, assign(socket, :fantasy_leagues, list_fantasy_leagues())}
  end

  defp list_fantasy_leagues do
    FantasyLeagues.list_fantasy_leagues()
  end
end
