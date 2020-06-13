defmodule Ex338Web.RulesLive do
  @moduledoc false
  use Ex338Web, :live_view

  alias Ex338.{Owner, Accounts}

  def mount(_params, session, socket) do
    %{"current_user_id" => current_user_id, "year" => year, "draft_method" => draft_method} =
      session

    socket = build_assigns(socket, current_user_id, year, draft_method)

    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <%= if !@exempt? do %>
      <br>
      <%= if @display_button? do %>
        <button phx-click="accept">Accept Rules</button>
      <% else %>
        <h4>✅ Accepted <%= "#{@year}" %> Rules!</h4> 
      <% end %>
    <% end %>
    """
  end

  def handle_event("accept", _, socket) do
    %{current_user: current_user, year: year, draft_method: draft_method} = socket.assigns

    Enum.each(socket.assigns.owners_for_league, fn owner ->
      Owner.Store.update_owner(owner, %{rules: "accepted"})
    end)

    socket = build_assigns(socket, current_user.id, year, draft_method)

    {:noreply, socket}
  end

  # Handlers

  defp build_assigns(socket, current_user_id, year, draft_method) do
    current_user = Accounts.get_user!(current_user_id)
    owners = filter_owners(current_user.owners, year, draft_method)
    display_button? = Enum.any?(owners, &(&1.rules == :unaccepted))
    exempt? = Enum.all?(owners, &(&1.rules == :exempt))

    socket
    |> assign(:display_button?, display_button?)
    |> assign(:exempt?, exempt?)
    |> assign(:owners_for_league, owners)
    |> assign(:current_user, current_user)
    |> assign(:year, year)
    |> assign(:draft_method, draft_method)
  end

  defp filter_owners(owners, year, draft_method) do
    Enum.filter(owners, fn owner ->
      owner.fantasy_team.fantasy_league.year == String.to_integer(year) &&
        Atom.to_string(owner.fantasy_team.fantasy_league.draft_method) == draft_method
    end)
  end
end
