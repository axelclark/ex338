defmodule Ex338Web.Commish.FantasyLeagueLive.Edit do
  @moduledoc false
  use Ex338Web, :live_view

  alias Ex338.FantasyLeagues
  alias Ex338Web.Components.Commish

  @impl true
  def render(assigns) do
    ~H"""
    <Commish.tabs current_route={@current_route} fantasy_league={@fantasy_league} />

    <.live_component
      module={Ex338Web.Commish.FantasyLeagueLive.FormComponent}
      id={@fantasy_league.id}
      title={@page_title}
      action={@live_action}
      fantasy_league={@fantasy_league}
      return_to={~p"/commish/fantasy_leagues/#{@fantasy_league}/edit"}
    >
    </.live_component>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    fantasy_league = FantasyLeagues.get_fantasy_league!(id)

    socket =
      socket
      |> assign(:page_title, "Edit Fantasy League")
      |> assign(:fantasy_league, fantasy_league)
      |> assign(
        :current_route,
        ~p"/commish/fantasy_leagues/#{fantasy_league}/edit"
      )

    {:noreply, socket}
  end
end
