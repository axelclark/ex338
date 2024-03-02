defmodule Ex338Web.DraftQueueHTML do
  use Ex338Web, :html

  def new(assigns) do
    ~H"""
    <.two_col_form
      :let={f}
      for={@changeset}
      action={~p"/fantasy_teams/#{@fantasy_team.id}/draft_queues"}
    >
      <:title>
        Submit new Draft Queue player
      </:title>
      <:description>
        Submit a new player for <%= @fantasy_team.team_name %>'s Draft
        Queue.  Don't forget to check your team's autodraft settings.
      </:description>
      <.input
        field={f[:sports_league]}
        label="Sports League"
        type="select"
        options={sports_abbrevs(@available_players)}
        class="sports-select-filter"
        prompt="Select sport to filter players"
      />

      <.input
        field={f[:fantasy_player_id]}
        label="Fantasy Player"
        type="select"
        options={format_players_for_select(@available_players)}
        class="players-to-filter"
        prompt="Select a fantasy player"
      />

      <:actions>
        <.submit_buttons back_route={~p"/fantasy_teams/#{@fantasy_team.id}"} />
      </:actions>
    </.two_col_form>
    """
  end
end
