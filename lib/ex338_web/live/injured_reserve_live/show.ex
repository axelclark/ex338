defmodule Ex338Web.InjuredReserveLive.Show do
  use Ex338Web, :live_view

  alias Ex338.InjuredReserves

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:injured_reserve, InjuredReserves.get_injured_reserve!(id))}
  end

  defp page_title(:show), do: "Show Injured reserve"
  defp page_title(:edit), do: "Edit Injured reserve"
end
