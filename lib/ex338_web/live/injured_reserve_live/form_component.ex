defmodule Ex338Web.InjuredReserveLive.FormComponent do
  use Ex338Web, :live_component

  alias Ex338.InjuredReserves

  @impl true
  def update(%{injured_reserve: injured_reserve} = assigns, socket) do
    changeset = InjuredReserves.change_injured_reserve(injured_reserve)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"injured_reserve" => injured_reserve_params}, socket) do
    changeset =
      socket.assigns.injured_reserve
      |> InjuredReserves.change_injured_reserve(injured_reserve_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"injured_reserve" => injured_reserve_params}, socket) do
    save_injured_reserve(socket, socket.assigns.action, injured_reserve_params)
  end

  defp save_injured_reserve(socket, :edit, injured_reserve_params) do
    case InjuredReserves.update_injured_reserve(socket.assigns.injured_reserve, injured_reserve_params) do
      {:ok, _injured_reserve} ->
        {:noreply,
         socket
         |> put_flash(:info, "Injured reserve updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_injured_reserve(socket, :new, injured_reserve_params) do
    case InjuredReserves.create_injured_reserve(injured_reserve_params) do
      {:ok, _injured_reserve} ->
        {:noreply,
         socket
         |> put_flash(:info, "Injured reserve created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
