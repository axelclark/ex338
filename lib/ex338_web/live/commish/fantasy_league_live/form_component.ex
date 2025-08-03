defmodule Ex338Web.Commish.FantasyLeagueLive.FormComponent do
  @moduledoc false
  use Ex338Web, :live_component

  import Ex338Web.CoreComponents

  alias Ex338.FantasyLeagues

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.two_col_form
        :let={f}
        id="fantasy_league-form"
        for={@changeset}
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        show_form_error={false}
      >
        <:title>
          {@title}
        </:title>
        <:description>
          Basic info and settings for a fantasy league
        </:description>

        <.input field={f[:fantasy_league_name]} label="Name" type="text" />
        <.input field={f[:year]} label="Year" type="number" />
        <.input field={f[:division]} label="Division" type="text" />
        <.input field={f[:only_flex?]} label="Only Flex?" type="checkbox" />
        <.input field={f[:must_draft_each_sport?]} label="Must draft each sport?" type="checkbox" />
        <.input
          field={f[:championships_start_at]}
          label="Championships Start At"
          type="datetime-local"
        />
        <.input field={f[:championships_end_at]} label="Championships End At" type="datetime-local" />
        <.input
          field={f[:navbar_display]}
          label="Navbar Display"
          type="select"
          prompt="Select where to display league"
          options={@navbar_display_options}
        />
        <.input
          field={f[:draft_method]}
          label="Draft Method"
          type="select"
          prompt="Select the type of draft"
          options={@draft_method_options}
        />
        <.input field={f[:max_draft_hours]} label="Max Draft Hours" type="number" />
        <.input field={f[:max_flex_spots]} label="Max Flex Spots" type="number" />

        <div class="sm:col-span-full">
          <h3 class="text-base font-medium text-gray-900 mb-4">Fantasy Teams</h3>
          <div class="divide-y divide-gray-200">
            <.inputs_for :let={team_form} field={f[:fantasy_teams]}>
              <div class="py-6 first:pt-0">
                <div class="space-y-4">
                  <.input field={team_form[:team_name]} type="text" label="Team Name" readonly="true" />
                  <.input
                    field={team_form[:draft_grade]}
                    type="text"
                    label="Draft Grade"
                    placeholder="A, B, C, D, F"
                  />
                  <div>
                    <label class="block text-sm font-medium leading-6 text-gray-900">
                      Draft Analysis
                    </label>
                    <.input
                      field={team_form[:draft_analysis]}
                      type="hidden"
                      id={"trix-editor-#{team_form[:id].value}"}
                    />
                    <div id={"trix-editor-wrapper-#{team_form[:id].value}"} phx-update="ignore">
                      <trix-editor input={"trix-editor-#{team_form[:id].value}"}></trix-editor>
                    </div>
                  </div>
                </div>
              </div>
            </.inputs_for>
          </div>
        </div>

        <:actions>
          <.submit_buttons back_route={~p"/commish/fantasy_leagues/#{@fantasy_league}/approvals"} />
        </:actions>
      </.two_col_form>
    </div>
    """
  end

  @impl true
  def update(%{fantasy_league: fantasy_league} = assigns, socket) do
    changeset = FantasyLeagues.change_league_as_commish(fantasy_league)

    socket =
      socket
      |> assign(assigns)
      |> assign(:changeset, changeset)
      |> assign(:navbar_display_options, FantasyLeagues.options_for_navbar_display())
      |> assign(:draft_method_options, FantasyLeagues.options_for_draft_method())

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"fantasy_league" => fantasy_league_params}, socket) do
    changeset =
      socket.assigns.fantasy_league
      |> FantasyLeagues.change_league_as_commish(fantasy_league_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"fantasy_league" => fantasy_league_params}, socket) do
    save_fantasy_league(socket, socket.assigns.action, fantasy_league_params)
  end

  defp save_fantasy_league(socket, :edit, fantasy_league_params) do
    case FantasyLeagues.update_league_as_commish(
           socket.assigns.fantasy_league,
           fantasy_league_params
         ) do
      {:ok, _fantasy_league} ->
        socket =
          socket
          |> put_flash(:info, "Fantasy league updated successfully")
          |> push_navigate(to: socket.assigns.return_to)

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        socket =
          socket
          |> put_flash(:error, "Check errors below")
          |> assign(:changeset, changeset)

        {:noreply, socket}
    end
  end
end
