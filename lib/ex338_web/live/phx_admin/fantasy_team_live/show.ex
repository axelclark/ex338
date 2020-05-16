defmodule Ex338Web.PhxAdmin.FantasyTeamLive.Show do
  use Ex338Web, :live_view

  alias Ex338.FantasyTeams

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:fantasy_team, FantasyTeams.get_fantasy_team!(id))}
  end

  defp page_title(:show), do: "Show Fantasy team"
  defp page_title(:edit), do: "Edit Fantasy team"
end
