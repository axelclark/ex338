defmodule Ex338Web.Commish.FantasyLeagueLive.FormComponent do
  use Ex338Web, :live_component

  alias Ex338.FantasyLeagues

  @impl true
  def update(%{fantasy_league: fantasy_league} = assigns, socket) do
    changeset = FantasyLeagues.change_fantasy_league(fantasy_league)

    socket =
      socket
      |> assign(assigns)
      |> assign(:changeset, changeset)
      |> assign(:navbar_display_options, FantasyLeagues.options_for_navbar_display())
      |> assign(:draft_method_options, FantasyLeagues.options_for_draft_method())

    {:ok, socket}
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
    case FantasyLeagues.update_fantasy_league(
           socket.assigns.fantasy_league,
           fantasy_league_params
         ) do
      {:ok, _fantasy_league} ->
        socket =
          socket
          |> put_flash(:info, "Fantasy league updated successfully")
          |> push_redirect(to: socket.assigns.return_to)

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        socket =
          socket
          |> put_flash(:error, "Check errors below")
          |> assign(:changeset, changeset)

        {:noreply, socket}
    end
  end
end
