defmodule Ex338Web.FantasyTeamDraftQueuesLive.EditFormComponent do
  @moduledoc false
  use Ex338Web, :live_component

  import Ex338Web.FantasyTeamComponents

  alias Ex338.FantasyTeams
  alias Ex338.FantasyTeams.FantasyTeam

  @impl true
  def update(%{fantasy_team: fantasy_team} = assigns, socket) do
    changeset = FantasyTeam.owner_changeset(fantasy_team)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"fantasy_team" => fantasy_team_params}, socket) do
    changeset =
      socket.assigns.fantasy_team
      |> FantasyTeam.owner_changeset(fantasy_team_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"fantasy_team" => fantasy_team_params}, socket) do
    case FantasyTeams.update_team(socket.assigns.fantasy_team, fantasy_team_params) do
      {:ok, fantasy_team} ->
        {:noreply,
         socket
         |> put_flash(:info, "Fantasy team draft queues updated successfully")
         |> redirect(to: ~p"/fantasy_teams/#{fantasy_team}")}

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
      <.form
        id="fantasy-team-draft-queues-form"
        for={@form}
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <div class="mt-6">
          <div class="md:grid md:grid-cols-3 md:gap-6">
            <div class="md:col-span-1">
              <div class="px-4 sm:px-0">
                <h3 class="text-lg font-medium text-gray-900 leading-6">
                  Update Team Draft Queues
                </h3>
                <p class="mt-1 text-sm text-gray-600 leading-5">
                  Update autodraft settings for draft queue and manage draft queues for your team
                </p>
              </div>
            </div>
            <div class="mt-5 md:mt-0 md:col-span-2">
              <div class="shadow sm:rounded-md sm:overflow-hidden">
                <div class="px-4 py-5 bg-white sm:p-6">
                  <div class="grid grid-cols-3 gap-6">
                    <div class="col-span-3 sm:col-span-2 space-y-6">
                      <.input
                        field={@form[:autodraft_setting]}
                        label="Autodraft Setting"
                        type="select"
                        options={FantasyTeam.autodraft_setting_options()}
                      />
                    </div>
                  </div>

                  <div class="mt-8 flex justify-center">
                    <.draft_queue_form form={@form} fantasy_team={@fantasy_team} />
                  </div>
                </div>

                <div class="flex flex-row justify-end px-4 py-3 sm:px-6 bg-gray-50 sm:justify-start">
                  <.submit_buttons
                    submit_text="Save Changes"
                    back_route={~p"/fantasy_teams/#{@fantasy_team.id}"}
                  />
                </div>
              </div>
            </div>
          </div>
        </div>
      </.form>
    </div>
    """
  end

  attr :form, :map, required: true
  attr :fantasy_team, :map, required: true

  def draft_queue_form(assigns) do
    ~H"""
    <div class="min-w-full md:max-w-md">
      <div class="-my-2 py-2 overflow-visible sm:-mx-6 sm:px-6 lg:-mx-8 lg:px-8">
        <div class="align-middle inline-block min-w-full shadow overflow-hidden sm:rounded-lg border-b border-gray-200">
          <table class="min-w-full">
            <thead>
              <tr>
                <th class="pl-4 pr-2 sm:px-6 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase tracking-wider">
                  Order
                </th>
                <th class="px-2 sm:px-6 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase tracking-wider">
                  Player
                </th>
                <th class="px-2 sm:px-6 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase tracking-wider">
                  Sport
                </th>
                <th class="pl-2 pr-4 sm:px-6 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase tracking-wider">
                  Status
                </th>
              </tr>
            </thead>
            <%= if @fantasy_team.draft_queues == []do %>
              <tbody class="bg-white">
                <td class="pl-4 pr-2 sm:px-6 py-2 whitespace-normal border-b border-gray-200 text-sm text-left leading-5 text-gray-500">
                  ---
                </td>
                <td class="px-2 sm:px-6 py-2 whitespace-normal border-b border-gray-200 text-sm text-left leading-5 text-gray-500">
                </td>
                <td class="px-2 sm:px-6 py-2 whitespace-normal border-b border-gray-200 text-sm text-left leading-5 text-gray-500">
                </td>
                <td class="pl-2 pr-4 sm:px-6 py-2 whitespace-no-wrap border-b border-gray-200 text-sm text-left leading-5 text-gray-500">
                </td>
              </tbody>
            <% else %>
              <tbody id="draft-queues" phx-hook="SortableInputsFor" class="bg-white">
                <.inputs_for :let={q} field={@form[:draft_queues]}>
                  <tr class="drag-item drag-item:focus-within:ring-0 drag-item:focus-within:ring-offset-0 drag-item:bg-white drag-ghost:bg-zinc-300 drag-ghost:border-0 drag-ghost:ring-0">
                    <td
                      data-handle={q.data.id}
                      class="cursor-pointer pl-4 pr-2 sm:px-6 py-2 whitespace-normal border-b border-gray-200 text-sm text-left leading-5 text-gray-500 drag-ghost:opacity-0"
                    >
                      <.icon name="hero-bars-3" />
                      <%= q.data.order %>
                      <input type="hidden" name="fantasy_team[draft_queues_order][]" value={q.index} />
                    </td>
                    <td class="px-2 sm:px-6 py-2 whitespace-normal border-b border-gray-200 text-sm text-left leading-5 text-gray-500 drag-ghost:opacity-0">
                      <%= q.data.fantasy_player.player_name %>
                      <.fantasy_player_id_errors field={q[:fantasy_player_id]} />
                    </td>
                    <td class="px-2 sm:px-6 py-2 whitespace-normal border-b border-gray-200 text-sm text-left leading-5 text-gray-500 drag-ghost:opacity-0">
                      <%= q.data.fantasy_player.sports_league.abbrev %>
                    </td>
                    <td class="pl-2 pr-4 sm:px-6 py-2 whitespace-no-wrap border-b border-gray-200 text-sm text-left leading-5 text-gray-500 drag-ghost:opacity-0">
                      <.input
                        field={q[:status]}
                        type="select"
                        options={queue_status_options()}
                        class="!mt-0"
                      />
                    </td>
                  </tr>
                </.inputs_for>
              </tbody>
            <% end %>
          </table>
        </div>
      </div>
    </div>
    """
  end

  attr :field, :map, required: true

  defp fantasy_player_id_errors(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: field.id)
    |> assign(:errors, Enum.map(field.errors, &translate_error(&1)))
    |> assign_new(:name, fn -> field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> fantasy_player_id_errors()
  end

  defp fantasy_player_id_errors(assigns) do
    ~H"""
    <div phx-feedback-for={@name}>
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end
end
