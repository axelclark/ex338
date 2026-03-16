defmodule Ex338Web.WaiverHTML do
  use Ex338Web, :html

  import Ex338Web.Components.Badge
  import Ex338Web.Components.Card
  import Ex338Web.Components.Table
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
    <div class="space-y-6">
      <div class="space-y-1">
        <p class="text-sm text-muted-foreground">Division {@fantasy_league.division}</p>
        <h1 class="text-3xl font-semibold tracking-tight">Waivers</h1>
      </div>

      <div class="grid grid-cols-1 gap-4 sm:grid-cols-3">
        <.card>
          <.card_header class="pb-2">
            <.card_description>Pending</.card_description>
            <.card_title class="text-2xl">{status_count(@waivers, "pending")}</.card_title>
          </.card_header>
        </.card>
        <.card>
          <.card_header class="pb-2">
            <.card_description>Successful</.card_description>
            <.card_title class="text-2xl">{status_count(@waivers, "successful")}</.card_title>
          </.card_header>
        </.card>
        <.card>
          <.card_header class="pb-2">
            <.card_description>Invalid</.card_description>
            <.card_title class="text-2xl">{status_count(@waivers, "invalid")}</.card_title>
          </.card_header>
        </.card>
      </div>

      <.pending_table waivers={@waivers} current_user={@current_user} />

      <p class="text-sm text-muted-foreground">
        * All dates and times are in Pacific Standard Time (PST)/Pacific Daylight Time (PDT).
      </p>
      <p class="text-sm text-muted-foreground">** Owners may only update the player to drop.</p>

      <.waiver_table waivers={@waivers} status="successful" current_user={@current_user} />
      <.waiver_table waivers={@waivers} status="invalid" current_user={@current_user} />
    </div>
    """
  end

  defp pending_table(assigns) do
    ~H"""
    <.card>
      <.card_header>
        <.card_title>Pending Approval</.card_title>
        <.card_description>Claims waiting for the waiver period to end.</.card_description>
      </.card_header>
      <.card_content>
        <div class="overflow-x-auto">
          <.table>
            <.table_header>
              <.table_row>
                <.table_head>Wait Period Ends*</.table_head>
                <.table_head>Team</.table_head>
                <.table_head class="text-center">Waiver Position</.table_head>
                <.table_head>Add Player</.table_head>
                <.table_head>Drop Player</.table_head>
                <.table_head>Actions**</.table_head>
              </.table_row>
            </.table_header>
            <.table_body>
              <.table_row :for={waiver <- @waivers} :if={waiver.status == "pending"}>
                <.table_cell>{short_datetime_pst(waiver.process_at)}</.table_cell>
                <.table_cell>
                  <.fantasy_team_name_link fantasy_team={waiver.fantasy_team} />
                </.table_cell>
                <.table_cell class="text-center tabular-nums">
                  {waiver.fantasy_team.waiver_position}
                </.table_cell>
                <.table_cell>{player_label(waiver.add_fantasy_player)}</.table_cell>
                <.table_cell>{player_label(waiver.drop_fantasy_player)}</.table_cell>
                <.table_cell>
                  <div class="flex flex-wrap gap-x-3 gap-y-1 text-sm">
                    <.link
                      :if={
                        after_now?(waiver.process_at) &&
                          (owner?(@current_user, waiver) || (@current_user && @current_user.admin))
                      }
                      href={~p"/waivers/#{waiver}/edit"}
                      class="text-primary hover:underline whitespace-nowrap"
                    >
                      Update
                    </.link>
                    <.link
                      :if={admin?(@current_user)}
                      href={~p"/waiver_admin/#{waiver.id}/edit"}
                      class="text-primary hover:underline whitespace-nowrap"
                    >
                      Process
                    </.link>
                  </div>
                </.table_cell>
              </.table_row>
            </.table_body>
          </.table>
        </div>
      </.card_content>
    </.card>
    """
  end

  defp waiver_table(assigns) do
    ~H"""
    <.card>
      <.card_header>
        <.card_title class="capitalize">{@status} claims</.card_title>
        <.card_description>Processed waiver outcomes.</.card_description>
      </.card_header>
      <.card_content>
        <div class="overflow-x-auto">
          <.table>
            <.table_header>
              <.table_row>
                <.table_head>{String.capitalize(@status)} Claim At*</.table_head>
                <.table_head>Team</.table_head>
                <.table_head>Add Player</.table_head>
                <.table_head>Drop Player</.table_head>
                <.table_head>Status</.table_head>
              </.table_row>
            </.table_header>
            <.table_body>
              <.table_row :for={waiver <- sort_most_recent(@waivers)} :if={waiver.status == @status}>
                <.table_cell>{short_datetime_pst(waiver.process_at)}</.table_cell>
                <.table_cell>
                  <.fantasy_team_name_link fantasy_team={waiver.fantasy_team} />
                </.table_cell>
                <.table_cell>{processed_player_label(waiver.add_fantasy_player)}</.table_cell>
                <.table_cell>{processed_player_label(waiver.drop_fantasy_player)}</.table_cell>
                <.table_cell>
                  <.badge variant={status_badge_variant(@status)}>
                    {String.capitalize(@status)}
                  </.badge>
                </.table_cell>
              </.table_row>
            </.table_body>
          </.table>
        </div>
      </.card_content>
    </.card>
    """
  end

  defp status_count(waivers, status), do: Enum.count(waivers, &(&1.status == status))

  defp player_label(nil), do: "—"

  defp player_label(player) do
    "#{display_name(player)} (#{player.sports_league.abbrev})"
  end

  defp processed_player_label(nil), do: "—"

  defp processed_player_label(player) do
    "#{player.player_name} (#{player.sports_league.abbrev})"
  end

  defp status_badge_variant("successful"), do: "default"
  defp status_badge_variant("invalid"), do: "destructive"
  defp status_badge_variant(_), do: "secondary"

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
