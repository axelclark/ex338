defmodule Ex338Web.ChampionshipLive.InSeasonDraftPickFormComponent do
  @moduledoc false
  use Ex338Web, :live_component

  alias Ex338.DraftQueues
  alias Ex338.InSeasonDraftPicks
  alias Ex338Web.InSeasonDraftPickNotifier

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        Submit <%= @in_season_draft_pick.championship.title %> Draft Pick
        <:subtitle>
          Please make a selection for <%= @in_season_draft_pick.draft_pick_asset.fantasy_team.team_name %>'s
          round <%= @in_season_draft_pick.position %> pick.
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="in-season-draft-pick-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        class="max-w-lg"
      >
        <.input
          field={@form[:drafted_player_id]}
          label="Player to Draft"
          type="select"
          options={format_players_for_select(@available_fantasy_players)}
          prompt="Select a fantasy player"
        />
        <:actions>
          <.button phx-disable-with="Submitting...">Submit Draft Pick</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{in_season_draft_pick: in_season_draft_pick} = assigns, socket) do
    changeset = InSeasonDraftPicks.change_in_season_draft_pick_as_owner(in_season_draft_pick)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"in_season_draft_pick" => in_season_draft_pick_params}, socket) do
    changeset =
      socket.assigns.in_season_draft_pick
      |> InSeasonDraftPicks.change_in_season_draft_pick_as_owner(in_season_draft_pick_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"in_season_draft_pick" => in_season_draft_pick_params}, socket) do
    case InSeasonDraftPicks.draft_player(
           socket.assigns.in_season_draft_pick,
           in_season_draft_pick_params
         ) do
      {:ok, %{update_pick: in_season_draft_pick}} ->
        DraftQueues.reorder_for_league(socket.assigns.fantasy_league.id)
        InSeasonDraftPickNotifier.send_update(in_season_draft_pick)

        {:noreply, push_patch(socket, to: socket.assigns.patch)}

      {:error, _multi_action, %Ecto.Changeset{} = changeset, _} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
