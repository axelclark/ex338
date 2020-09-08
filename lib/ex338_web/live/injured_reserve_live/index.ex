defmodule Ex338Web.InjuredReserveLive.Index do
  use Ex338Web, :live_view

  alias Ex338.InjuredReserves
  alias Ex338.InjuredReserves.InjuredReserve

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :injured_reserves, list_injured_reserves())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Injured reserve")
    |> assign(:injured_reserve, InjuredReserves.get_injured_reserve!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Injured reserve")
    |> assign(:injured_reserve, %InjuredReserve{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Injured reserves")
    |> assign(:injured_reserve, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    injured_reserve = InjuredReserves.get_injured_reserve!(id)
    {:ok, _} = InjuredReserves.delete_injured_reserve(injured_reserve)

    {:noreply, assign(socket, :injured_reserves, list_injured_reserves())}
  end

  defp list_injured_reserves do
    InjuredReserves.list_injured_reserves()
  end
end
