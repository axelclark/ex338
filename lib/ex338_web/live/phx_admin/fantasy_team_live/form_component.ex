defmodule Ex338Web.PhxAdmin.FantasyTeamLive.FormComponent do
  use Ex338Web, :live_component

  alias Ex338.FantasyTeams

  @impl true
  def update(%{fantasy_team: fantasy_team} = assigns, socket) do
    changeset = FantasyTeams.change_fantasy_team(fantasy_team)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"fantasy_team" => fantasy_team_params}, socket) do
    changeset =
      socket.assigns.fantasy_team
      |> FantasyTeams.change_fantasy_team(fantasy_team_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"fantasy_team" => fantasy_team_params}, socket) do
    save_fantasy_team(socket, socket.assigns.action, fantasy_team_params)
  end

  defp save_fantasy_team(socket, :edit, fantasy_team_params) do
    case FantasyTeams.update_fantasy_team(socket.assigns.fantasy_team, fantasy_team_params) do
      {:ok, _fantasy_team} ->
        {:noreply,
         socket
         |> put_flash(:info, "Fantasy team updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_fantasy_team(socket, :new, fantasy_team_params) do
    case FantasyTeams.create_fantasy_team(fantasy_team_params) do
      {:ok, _fantasy_team} ->
        {:noreply,
         socket
         |> put_flash(:info, "Fantasy team created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
