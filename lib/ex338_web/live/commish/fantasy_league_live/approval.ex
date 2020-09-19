defmodule Ex338Web.Commish.FantasyLeagueLive.Approval do
  use Ex338Web, :live_view

  alias Ex338.{Accounts, FantasyLeagues, InjuredReserves}

  @impl true
  def mount(_params, %{"current_user_id" => user_id}, socket) do
    current_user =
      user_id
      |> Accounts.get_user!()
      |> Accounts.load_user_teams()

    {:ok, assign(socket, :current_user, current_user)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    fantasy_league = FantasyLeagues.get_fantasy_league!(id)

    socket =
      socket
      |> assign(:fantasy_league, fantasy_league)
      |> assign(:injured_reserves, fetch_injured_reserves(fantasy_league))
      |> assign(
        :current_route,
        Routes.commish_fantasy_league_approval_path(socket, :index, fantasy_league)
      )

    {:noreply, socket}
  end

  @impl true
  def handle_event("update_injured_reserve", %{"id" => id} = params, socket) do
    socket =
      id
      |> InjuredReserves.get_ir!()
      |> InjuredReserves.update_injured_reserve(params)
      |> handle_update(socket)

    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    Phoenix.View.render(Ex338Web.Commish.FantasyLeagueView, "approval.html", assigns)
  end

  # Helpers

  defp fetch_injured_reserves(fantasy_league) do
    for_commish_action = [statuses: [:submitted, :approved]]
    query_criteria = Keyword.put(for_commish_action, :fantasy_league, fantasy_league)

    InjuredReserves.list_injured_reserves(query_criteria)
  end

  defp handle_update({:ok, %{injured_reserve: _injured_reserve}}, socket) do
    socket
    |> put_flash(:info, "IR successfully processed")
    |> assign(:injured_reserves, fetch_injured_reserves(socket.assigns.fantasy_league))
  end

  defp handle_update({:error, _action, error, _}, socket) do
    put_flash(socket, :error, parse_errors(error))
  end

  defp parse_errors(error) when is_binary(error), do: error

  defp parse_errors(changeset) do
    Enum.reduce(changeset.errors, "", fn {_field, {error, _details}}, message ->
      error <> " " <> message
    end)
  end
end
