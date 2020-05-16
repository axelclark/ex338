defmodule Ex338Web.PhxAdmin.FantasyTeamLive.Index do
  use Ex338Web, :live_view

  alias Ex338.FantasyTeams
  alias Ex338.FantasyTeam

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :fantasy_teams, fetch_fantasy_teams())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Fantasy team")
    |> assign(:fantasy_team, FantasyTeams.get_fantasy_team!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Fantasy team")
    |> assign(:fantasy_team, %FantasyTeam{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Fantasy teams")
    |> assign(:fantasy_team, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    fantasy_team = FantasyTeams.get_fantasy_team!(id)
    {:ok, _} = FantasyTeams.delete_fantasy_team(fantasy_team)

    {:noreply, assign(socket, :fantasy_teams, fetch_fantasy_teams())}
  end

  defp fetch_fantasy_teams do
    FantasyTeams.list_fantasy_teams()
  end
end
