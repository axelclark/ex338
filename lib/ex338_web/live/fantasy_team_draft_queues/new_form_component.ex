defmodule Ex338Web.FantasyTeamDraftQueuesLive.NewFormComponent do
  @moduledoc false
  use Ex338Web, :live_component

  alias Ex338.DraftQueues
  alias Ex338.DraftQueues.DraftQueue
  alias Ex338.FantasyPlayers

  @impl true
  def update(assigns, socket) do
    %{fantasy_team: fantasy_team, draft_queue: draft_queue} = assigns
    fantasy_league = fantasy_team.fantasy_league

    available_players = get_available_players(fantasy_league)
    changeset = DraftQueue.changeset(draft_queue)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:available_players, available_players)
     |> assign(:fantasy_team, fantasy_team)
     |> assign(:fantasy_league, fantasy_league)
     |> assign_form(changeset)}
  end

  defp get_available_players(%{id: id, sport_draft_id: nil}) do
    FantasyPlayers.available_players(id)
  end

  defp get_available_players(%{id: id, sport_draft_id: sport_id}) do
    FantasyPlayers.get_avail_players_for_sport(id, sport_id)
  end

  @impl true
  def handle_event("validate", %{"draft_queue" => draft_queue_params}, socket) do
    changeset =
      socket.assigns.draft_queue
      |> DraftQueue.changeset(draft_queue_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"draft_queue" => draft_queue_params}, socket) do
    draft_queue_params =
      Map.put(draft_queue_params, "fantasy_team_id", socket.assigns.fantasy_team.id)

    case DraftQueues.create_draft_queue(draft_queue_params) do
      {:ok, draft_queue} ->
        draft_queue = Ex338.Repo.preload(draft_queue, :fantasy_player)

        {:noreply,
         socket
         |> put_flash(:info, "Draft queue added for #{draft_queue.fantasy_player.player_name}")
         |> push_patch(to: ~p"/fantasy_teams/#{socket.assigns.fantasy_team.id}/draft_queues/edit")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.two_col_form id="new-draft-queue-form" for={@form} phx-target={@myself} phx-submit="save">
        <:title>
          Submit new Draft Queue player
        </:title>
        <:description>
          Submit a new player for <%= @fantasy_team.team_name %>'s Draft
          Queue.  Don't forget to check your team's autodraft settings.
        </:description>
        <.input
          field={@form[:sports_league]}
          label="Sports League"
          type="select"
          options={sports_abbrevs(@available_players)}
          class="sports-select-filter"
          prompt="Select sport to filter players"
        />

        <.input
          field={@form[:fantasy_player_id]}
          label="Fantasy Player"
          type="select"
          options={format_players_for_select(@available_players)}
          class="players-to-filter"
          prompt="Select a fantasy player"
        />

        <:actions>
          <.submit_buttons submit_text="Add" back_route={~p"/fantasy_teams/#{@fantasy_team.id}"} />
        </:actions>
      </.two_col_form>
    </div>
    """
  end
end
