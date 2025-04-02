defmodule Ex338Web.RulesLive do
  @moduledoc false
  use Ex338Web, :live_view

  alias Ex338.Accounts
  alias Ex338.FantasyLeagues
  alias Ex338.FantasyTeams

  def mount(_params, session, socket) do
    %{
      "current_user_id" => current_user_id,
      "fantasy_league_id" => fantasy_league_id
    } = session

    fantasy_league = FantasyLeagues.get(fantasy_league_id)
    socket = build_assigns(socket, current_user_id, fantasy_league)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <%= if !@exempt? do %>
      <%= if @display_button? do %>
        <span class="inline-flex rounded-md shadow-xs">
          <button
            phx-click="accept"
            type="button"
            class="inline-flex items-center px-4 py-2 text-base font-medium text-white bg-green-600 border border-transparent leading-6 rounded-md hover:bg-green-500 focus:outline-hidden focus:border-green-700 focus:shadow-outline-green active:bg-green-700 transition ease-in-out duration-150"
          >
            <svg
              class="w-5 h-5 mr-3 -ml-1"
              fill="none"
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              viewBox="0 0 20 20"
              stroke="currentColor"
            >
              <path d="M5 13l4 4L19 7"></path>
            </svg>
            Accept Rules
          </button>
        </span>
      <% else %>
        <p class="text-lg text-gray-900">
          ✅ Accepted {"#{@fantasy_league.year}"} Rules!
        </p>
      <% end %>
    <% end %>
    """
  end

  def handle_event("accept", _, socket) do
    %{current_user: current_user, fantasy_league: fantasy_league} = socket.assigns

    Enum.each(socket.assigns.owners_for_league, fn owner ->
      FantasyTeams.update_owner(owner, %{rules: "accepted"})
    end)

    socket = build_assigns(socket, current_user.id, fantasy_league)

    {:noreply, socket}
  end

  # Handlers

  defp build_assigns(socket, current_user_id, fantasy_league) do
    current_user = Accounts.get_user!(current_user_id)
    owners = filter_owners(current_user.owners, fantasy_league)
    display_button? = Enum.any?(owners, &(&1.rules == :unaccepted))
    exempt? = Enum.all?(owners, &(&1.rules == :exempt))

    socket
    |> assign(:display_button?, display_button?)
    |> assign(:exempt?, exempt?)
    |> assign(:owners_for_league, owners)
    |> assign(:current_user, current_user)
    |> assign(:fantasy_league, fantasy_league)
  end

  defp filter_owners(owners, fantasy_league) do
    Enum.filter(owners, fn owner ->
      owner.fantasy_team.fantasy_league.year == fantasy_league.year &&
        owner.fantasy_team.fantasy_league.draft_method ==
          fantasy_league.draft_method
    end)
  end
end
