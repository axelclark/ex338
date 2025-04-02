defmodule Ex338Web.FantasyTeamLive.Edit do
  @moduledoc false
  use Ex338Web, :live_view

  import Ex338Web.FantasyTeamComponents

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
         |> put_flash(:error, "Not authorized to edit that Fantasy Team")
         |> push_navigate(to: ~p"/fantasy_teams/#{id}")}

      nil ->
        {:noreply,
         socket
         |> put_flash(:error, "Fantasy Team not found")
         |> push_navigate(to: ~p"/")}
    end
  end

  defp assign_defaults(socket, fantasy_team) do
    changeset = FantasyTeam.owner_changeset(fantasy_team)

    socket
    |> assign(:fantasy_team, fantasy_team)
    |> assign(:fantasy_league, fantasy_team.fantasy_league)
    |> assign_form(changeset)
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
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
         |> put_flash(:info, "Fantasy team updated successfully")
         |> push_navigate(to: ~p"/fantasy_teams/#{fantasy_team}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.form id="fantasy-team-form" for={@form} phx-change="validate" phx-submit="save">
      <div class="mt-6">
        <div class="md:grid md:grid-cols-3 md:gap-6">
          <div class="md:col-span-1">
            <div class="px-4 sm:px-0">
              <h3 class="text-lg font-medium text-gray-900 leading-6">
                Update Team Info
              </h3>
              <p class="mt-1 text-sm text-gray-600 leading-5">
                Update team name and set autodraft settings for draft queue
              </p>
            </div>
          </div>
          <div class="mt-5 md:mt-0 md:col-span-2">
            <div class="shadow-sm sm:rounded-md sm:overflow-hidden">
              <div class="px-4 py-5 bg-white sm:p-6">
                <div class="grid grid-cols-3 gap-6">
                  <div class="col-span-3 sm:col-span-2 space-y-6">
                    <.input field={@form[:team_name]} label="Team Name" type="text" />
                    <.input
                      field={@form[:autodraft_setting]}
                      label="Autodraft Setting"
                      type="select"
                      options={FantasyTeam.autodraft_setting_options()}
                    />
                  </div>
                </div>
              </div>

              <div class="flex flex-row justify-end px-4 py-3 sm:px-6 bg-gray-50 sm:justify-start">
                <.submit_buttons back_route={~p"/fantasy_teams/#{@fantasy_team.id}"} />
              </div>
            </div>
          </div>
        </div>
      </div>
      <div class="hidden sm:block">
        <div class="py-5">
          <div class="border-t border-gray-300"></div>
        </div>
      </div>
      <div class="mt-10 sm:mt-0">
        <div class="md:grid md:grid-cols-3 md:gap-6">
          <div class="md:col-span-1">
            <div class="px-4 sm:px-0">
              <h3 class="text-lg font-medium text-gray-900 leading-6">
                Roster Positions
              </h3>
              <p class="mt-1 text-sm text-gray-600 leading-5">
                Update roster positions for your team
              </p>
            </div>
          </div>
          <div class="mt-5 md:mt-0 md:col-span-2">
            <div class="overflow-hidden shadow-sm sm:rounded-md">
              <div class="bg-white sm:p-6">
                <div class="flex justify-center">
                  <.roster_positions_form form={@form} fantasy_team={@fantasy_team} />
                </div>
              </div>

              <div class="flex flex-row justify-end px-4 py-3 sm:px-6 bg-gray-50 sm:justify-start">
                <.submit_buttons back_route={~p"/fantasy_teams/#{@fantasy_team.id}"} />
              </div>
            </div>
          </div>
        </div>
      </div>
    </.form>
    """
  end

  attr :form, :map, required: true
  attr :fantasy_team, :map, required: true

  def roster_positions_form(assigns) do
    ~H"""
    <div class="min-w-full md:max-w-md">
      <div class="-my-2 py-2 overflow-visible sm:-mx-6 sm:px-6 lg:-mx-8 lg:px-8">
        <div class="align-middle inline-block min-w-full shadow-sm overflow-hidden sm:rounded-lg border-b border-gray-200">
          <table class="min-w-full">
            <thead>
              <tr>
                <th class="pl-4 pr-2 sm:px-6 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase tracking-wider">
                  Position
                </th>
                <th class="px-2 sm:px-6 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase tracking-wider">
                  Player
                </th>
                <th class="pl-2 pr-4 sm:px-6 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase tracking-wider">
                  Sport
                </th>
              </tr>
            </thead>
            <tbody class="bg-white">
              <%= if @fantasy_team.roster_positions == []do %>
                <td class="pl-4 pr-2 sm:px-6 py-1 whitespace-normal border-b border-gray-200 text-sm text-left leading-5 text-gray-500">
                  ---
                </td>
                <td class="px-2 sm:px-6 py-2 whitespace-normal border-b border-gray-200 text-sm text-left leading-5 text-gray-500">
                </td>
                <td class="px-2 sm:px-6 py-2 whitespace-normal border-b border-gray-200 text-sm text-left leading-5 text-gray-500">
                </td>
                <td class="pl-2 pr-4 sm:px-6 py-2 whitespace-normal border-b border-gray-200 text-sm text-left leading-5 text-gray-500">
                </td>
              <% else %>
                <.inputs_for :let={r} field={@form[:roster_positions]}>
                  <tr>
                    <td class="pl-4 pr-2 sm:px-6 py-1 whitespace-normal border-b border-gray-200 text-sm text-left leading-5 text-gray-500">
                      <.input
                        field={r[:position]}
                        type="select"
                        options={position_selections(r, @fantasy_team.fantasy_league)}
                        class="mt-0!"
                      />
                    </td>
                    <td
                      class="px-2 sm:px-6 py-2 whitespace-normal break-words border-b border-gray-200 text-sm text-left leading-5 text-gray-500"
                      style="word-break: break-word;"
                    >
                      {if r.data.fantasy_player, do: r.data.fantasy_player.player_name}
                    </td>
                    <td class="pl-2 pr-4 sm:px-6 py-2 whitespace-normal border-b border-gray-200 text-sm text-left leading-5 text-gray-500">
                      <div class="flex items-center">
                        {if r.data.fantasy_player, do: r.data.fantasy_player.sports_league.abbrev}
                      </div>
                    </td>
                  </tr>
                </.inputs_for>
              <% end %>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    """
  end
end
