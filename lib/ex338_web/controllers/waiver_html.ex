defmodule Ex338Web.WaiverHTML do
  use Ex338Web, :html

  import Ex338Web.CoreComponents

  def new(assigns) do
    ~H"""
    <.two_col_form :let={f} for={@changeset} action={~p"/fantasy_teams/#{@fantasy_team.id}/waivers"}>
      <:title>
        Submit a new Waiver for {@fantasy_team.team_name}
      </:title>
      <:description>
        {@fantasy_team.team_name}'s current waiver position is {@fantasy_team.waiver_position}.
      </:description>

      <.input
        field={f[:drop_fantasy_player_id]}
        label="Player to Drop"
        type="select"
        options={format_players_for_select(@owned_players)}
        prompt="Select a player to drop"
      />

      <.input
        field={f[:sports_league]}
        label="Sports League"
        type="select"
        options={sports_abbrevs(@avail_players)}
        class="sports-select-filter"
        prompt="Select sport to filter players"
      />

      <.input
        field={f[:add_fantasy_player_id]}
        label="Player to Add"
        type="select"
        options={format_players_for_select(@avail_players)}
        class="players-to-filter"
        prompt="Select player to add"
      />
      <:actions>
        <.submit_buttons back_route={~p"/fantasy_teams/#{@fantasy_team}"} />
      </:actions>
    </.two_col_form>
    """
  end

  def edit(assigns) do
    ~H"""
    <.two_col_form :let={f} for={@changeset} action={~p"/waivers/#{@waiver}"}>
      <:title>
        Update Waiver
      </:title>
      <:description>
        {@waiver.fantasy_team.team_name}'s current waiver position is {@waiver.fantasy_team.waiver_position}.
      </:description>

      <p class="mb-4 font-medium text-gray-700 leading-5">
        Add Fantasy Player:
        <%= if @waiver.add_fantasy_player do %>
          {@waiver.add_fantasy_player.player_name}
        <% else %>
          "--"
        <% end %>
      </p>

      <.input
        field={f[:drop_fantasy_player_id]}
        label="Player to Drop"
        type="select"
        options={format_players_for_select(@owned_players)}
        prompt="Select a player to drop"
      />

      <.input
        field={f[:status]}
        label="Select status for the waiver"
        type="select"
        options={Ex338.Waivers.Waiver.status_options_for_team_update()}
      />

      <:actions>
        <.submit_buttons back_route={~p"/fantasy_leagues/#{@fantasy_league}/waivers"} />
      </:actions>
    </.two_col_form>
    """
  end

  def index(assigns) do
    ~H"""
    <.page_header>
      Waivers for Division {@fantasy_league.division}
    </.page_header>

    <h3 class="py-2 pl-4 text-base text-gray-700 sm:pl-6">
      Pending Approval
    </h3>

    <.pending_table waivers={@waivers} current_user={@current_user} />

    <p class="pl-4 mt-1 text-sm font-medium text-gray-700 leading-5 sm:mt-2 sm:pl-6">
      * All dates and times are in Pacific Standard Time (PST)/Pacific Daylight Time (PDT).
    </p>
    <p class="pl-4 mt-1 text-sm font-medium text-gray-700 leading-5 sm:mt-2 sm:pl-6">
      ** Owners may only update the player to drop.
    </p>

    <.section_header>
      Successful Claims
    </.section_header>

    <.waiver_table waivers={@waivers} status="successful" current_user={@current_user} />

    <.section_header>
      Invalid Claims
    </.section_header>
    {# render "table.html", waivers: @waivers, status: "invalid", current_user: @current_user, conn: @conn}
    """
  end

  defp pending_table(assigns) do
    ~H"""
    <div class="flex flex-col">
      <div class="py-2 -my-2 overflow-x-auto sm:-mx-6 sm:px-6 lg:-mx-8 lg:px-8">
        <div class="inline-block min-w-full overflow-hidden align-middle border-b border-gray-200 shadow sm:rounded-lg">
          <.legacy_table class="min-w-full">
            <thead>
              <tr>
                <.legacy_th>
                  Wait Period Ends*
                </.legacy_th>
                <.legacy_th>
                  Team
                </.legacy_th>
                <.legacy_th class="text-center">
                  Waiver Position
                </.legacy_th>
                <.legacy_th>
                  Add Player
                </.legacy_th>
                <.legacy_th>
                  Drop Player
                </.legacy_th>
                <.legacy_th>
                  Actions**
                </.legacy_th>
              </tr>
            </thead>
            <tbody class="bg-white">
              <%= for waiver <- @waivers, waiver.status == "pending" do %>
                <tr>
                  <.legacy_td>
                    {short_datetime_pst(waiver.process_at)}
                  </.legacy_td>
                  <.legacy_td class="text-indigo-700">
                    <.fantasy_team_name_link fantasy_team={waiver.fantasy_team} />
                  </.legacy_td>
                  <.legacy_td class="text-center">
                    {waiver.fantasy_team.waiver_position}
                  </.legacy_td>

                  <%= if waiver.add_fantasy_player do %>
                    <.legacy_td>
                      {display_name(waiver.add_fantasy_player)} ({waiver.add_fantasy_player.sports_league.abbrev})
                    </.legacy_td>
                  <% else %>
                    <.legacy_td></.legacy_td>
                  <% end %>

                  <%= if waiver.drop_fantasy_player do %>
                    <.legacy_td>
                      {waiver.drop_fantasy_player.player_name} ({waiver.drop_fantasy_player.sports_league.abbrev})
                    </.legacy_td>
                  <% else %>
                    <.legacy_td></.legacy_td>
                  <% end %>

                  <.legacy_td>
                    <%= if after_now?(waiver.process_at) && (owner?(@current_user, waiver) || @current_user && @current_user.admin) do %>
                      <.link href={~p"/waivers/#{waiver}/edit"} class="text-indigo-700">Update</.link>
                    <% end %>
                    <%= if admin?(@current_user) do %>
                      <.link
                        href={~p"/waiver_admin/#{waiver.id}/edit"}
                        class="last:ml-1 text-indigo-700"
                      >
                        Process
                      </.link>
                    <% end %>
                  </.legacy_td>
                </tr>
              <% end %>
            </tbody>
          </.legacy_table>
        </div>
      </div>
    </div>
    """
  end

  defp waiver_table(assigns) do
    ~H"""
    <.legacy_table class="lg:max-w-4xl">
      <thead>
        <tr>
          <.legacy_th>
            {@status} Claim At*
          </.legacy_th>
          <.legacy_th>
            Team
          </.legacy_th>
          <.legacy_th>
            Add Player
          </.legacy_th>
          <.legacy_th>
            Drop Player
          </.legacy_th>
        </tr>
      </thead>
      <tbody class="bg-white">
        <%= for waiver <- sort_most_recent(@waivers), waiver.status == @status do %>
          <tr>
            <.legacy_td>
              {short_datetime_pst(waiver.process_at)}
            </.legacy_td>
            <.legacy_td class="text-indigo-700">
              <.fantasy_team_name_link fantasy_team={waiver.fantasy_team} />
            </.legacy_td>
            <%= if waiver.add_fantasy_player do %>
              <.legacy_td>
                {waiver.add_fantasy_player.player_name} ({waiver.add_fantasy_player.sports_league.abbrev})
              </.legacy_td>
            <% else %>
              <.legacy_td></.legacy_td>
            <% end %>
            <%= if waiver.drop_fantasy_player do %>
              <.legacy_td>
                {waiver.drop_fantasy_player.player_name} ({waiver.drop_fantasy_player.sports_league.abbrev})
              </.legacy_td>
            <% else %>
              <.legacy_td></.legacy_td>
            <% end %>
          </tr>
        <% end %>
      </tbody>
    </.legacy_table>
    """
  end

  def after_now?(date_time) do
    case DateTime.compare(date_time, DateTime.utc_now()) do
      :gt -> true
      :eq -> true
      :lt -> false
    end
  end

  def sort_most_recent(query) do
    Enum.sort(query, &before_other_date?(&1.process_at, &2.process_at))
  end

  def display_name(%{sports_league: %{hide_waivers: true}}), do: "*****"

  def display_name(%{player_name: name} = _player), do: name

  def within_two_hours_of_submittal?(waiver) do
    submitted_at = waiver.inserted_at
    now = NaiveDateTime.utc_now()
    two_hours = 60 * 60 * 2
    age_of_waiver = NaiveDateTime.diff(now, submitted_at, :second)

    age_of_waiver < two_hours
  end

  # Helpers

  # sort_most_recent

  defp before_other_date?(date1, date2) do
    case DateTime.compare(date1, date2) do
      :gt -> true
      :eq -> true
      :lt -> false
    end
  end
end
