defmodule Ex338Web.Commish.FantasyLeagueLive.Approval do
  @moduledoc false
  use Ex338Web, :live_view

  alias Ex338.Accounts
  alias Ex338.DraftPicks
  alias Ex338.FantasyLeagues
  alias Ex338.InjuredReserves
  alias Ex338.Trades

  @impl true
  def mount(_params, %{"current_user_id" => user_id}, socket) do
    current_user =
      user_id
      |> Accounts.get_user!()
      |> Accounts.load_user_teams()

    socket =
      socket
      |> assign(:current_user, current_user)
      |> assign(:filter, :league)

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    fantasy_league = FantasyLeagues.get_fantasy_league!(id)
    socket = assign(socket, :fantasy_league, fantasy_league)

    socket =
      socket
      |> assign(:injured_reserves, fetch_injured_reserves(socket.assigns))
      |> assign(:trades, fetch_trades(socket.assigns))
      |> assign(
        :current_route,
        Routes.commish_fantasy_league_approval_path(socket, :index, fantasy_league)
      )
      |> assign(:future_picks, fetch_future_picks(socket.assigns))

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

  def handle_event("update_trade", %{"id" => id} = params, socket) do
    socket =
      id
      |> Trades.update_trade(params)
      |> handle_update(socket)

    {:noreply, socket}
  end

  def handle_event("toggle_league_filter", _params, socket) do
    socket = assign(socket, :filter, toggle_filter(socket))

    socket =
      socket
      |> assign(:injured_reserves, fetch_injured_reserves(socket.assigns))
      |> assign(:trades, fetch_trades(socket.assigns))

    {:noreply, socket}
  end

  def handle_event("create_future_picks", _params, socket) do
    %{fantasy_league: fantasy_league} = socket.assigns
    rounds = 20

    future_picks = FantasyLeagues.create_future_picks_for_league(fantasy_league.id, rounds)

    socket =
      socket
      |> assign(:future_picks, future_picks)
      |> put_flash(:info, "Successfully created 20 rounds of future picks")

    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    Phoenix.View.render(Ex338Web.Commish.FantasyLeagueView, "approval.html", assigns)
  end

  # Helpers

  defp fetch_injured_reserves(%{filter: :league, fantasy_league: fantasy_league}) do
    for_commish_action = [statuses: [:submitted, :approved]]
    query_criteria = Keyword.put(for_commish_action, :fantasy_league, fantasy_league)

    InjuredReserves.list_injured_reserves(query_criteria)
  end

  defp fetch_injured_reserves(%{filter: :all}) do
    query_for_commish_action = [statuses: [:submitted, :approved]]

    InjuredReserves.list_injured_reserves(query_for_commish_action)
  end

  defp fetch_trades(%{filter: :league, fantasy_league: fantasy_league}) do
    for_commish_action = [statuses: ["Proposed", "Pending"]]
    query_criteria = Keyword.put(for_commish_action, :fantasy_league, fantasy_league)
    Trades.list_trades(query_criteria)
  end

  defp fetch_trades(%{filter: :all}) do
    query_for_commish_action = [statuses: ["Proposed", "Pending"]]
    Trades.list_trades(query_for_commish_action)
  end

  defp fetch_future_picks(%{fantasy_league: fantasy_league}) do
    DraftPicks.list_future_picks_by_league(fantasy_league.id)
  end

  def toggle_filter(%{assigns: %{filter: :all}}), do: :league
  def toggle_filter(%{assigns: %{filter: :league}}), do: :all

  defp handle_update({:ok, %{injured_reserve: _injured_reserve}}, socket) do
    socket
    |> put_flash(:info, "IR successfully processed")
    |> assign(:injured_reserves, fetch_injured_reserves(socket.assigns))
  end

  defp handle_update({:ok, %{trade: _trade}}, socket) do
    socket
    |> put_flash(:info, "Trade successfully processed")
    |> assign(:trades, fetch_trades(socket.assigns))
  end

  defp handle_update({:error, _action, error, _}, socket) do
    put_flash(socket, :error, parse_errors(error))
  end

  defp handle_update({:error, error}, socket) do
    put_flash(socket, :error, inspect(error))
  end

  defp parse_errors(error) when is_binary(error), do: error

  defp parse_errors(changeset) do
    Enum.reduce(changeset.errors, "", fn {_field, {error, _details}}, message ->
      error <> " " <> message
    end)
  end
end
