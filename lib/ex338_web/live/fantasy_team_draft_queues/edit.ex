defmodule Ex338Web.FantasyTeamDraftQueuesLive.Edit do
  @moduledoc false
  use Ex338Web, :live_view

  alias Ex338.DraftQueues.DraftQueue
  alias Ex338.FantasyTeamAuthorizer
  alias Ex338.FantasyTeams
  alias Ex338.FantasyTeams.FantasyTeam

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    with %FantasyTeam{} = fantasy_team <- FantasyTeams.find_for_edit(id),
         :ok <-
           FantasyTeamAuthorizer.authorize(:edit_team, socket.assigns.current_user, fantasy_team) do
      {:noreply, assign_defaults(socket, fantasy_team)}
    else
      {:error, :not_authorized} ->
        {:noreply,
         socket
         |> put_flash(:error, "Not authorized to edit that Fantasy Team's draft queues")
         |> push_navigate(to: ~p"/fantasy_teams/#{id}")}

      nil ->
        {:noreply,
         socket
         |> put_flash(:error, "Fantasy Team not found")
         |> push_navigate(to: ~p"/")}
    end
  end

  defp assign_defaults(socket, fantasy_team) do
    socket
    |> assign(:fantasy_team, fantasy_team)
    |> assign(:fantasy_league, fantasy_team.fantasy_league)
    |> assign(:new_draft_queue, %DraftQueue{})
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        module={Ex338Web.FantasyTeamDraftQueuesLive.NewFormComponent}
        id={:new}
        fantasy_team={@fantasy_team}
        draft_queue={@new_draft_queue}
      />
      <.live_component
        module={Ex338Web.FantasyTeamDraftQueuesLive.EditFormComponent}
        id={@fantasy_team.id}
        fantasy_team={@fantasy_team}
      />
    </div>
    """
  end
end
