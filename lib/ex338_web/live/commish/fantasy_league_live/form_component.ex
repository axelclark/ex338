defmodule Ex338Web.Commish.FantasyLeagueLive.FormComponent do
  use Ex338Web, :live_component

  alias Ex338.FantasyLeagues

  @impl true
  def update(%{fantasy_league: fantasy_league} = assigns, socket) do
    changeset = FantasyLeagues.change_fantasy_league(fantasy_league)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"fantasy_league" => fantasy_league_params}, socket) do
    changeset =
      socket.assigns.fantasy_league
      |> FantasyLeagues.change_fantasy_league(fantasy_league_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"fantasy_league" => fantasy_league_params}, socket) do
    save_fantasy_league(socket, socket.assigns.action, fantasy_league_params)
  end

  defp save_fantasy_league(socket, :edit, fantasy_league_params) do
    case FantasyLeagues.update_fantasy_league(socket.assigns.fantasy_league, fantasy_league_params) do
      {:ok, _fantasy_league} ->
        {:noreply,
         socket
         |> put_flash(:info, "Fantasy league updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_fantasy_league(socket, :new, fantasy_league_params) do
    case FantasyLeagues.create_fantasy_league(fantasy_league_params) do
      {:ok, _fantasy_league} ->
        {:noreply,
         socket
         |> put_flash(:info, "Fantasy league created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
