defmodule Ex338Web.Commish.FantasyLeagueLive.Show do
  use Ex338Web, :live_view

  alias Ex338.FantasyLeagues

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:fantasy_league, FantasyLeagues.get_fantasy_league!(id))}
  end

  defp page_title(:show), do: "Show Fantasy league"
  defp page_title(:edit), do: "Edit Fantasy league"
end
