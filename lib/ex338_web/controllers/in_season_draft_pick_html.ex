defmodule Ex338Web.InSeasonDraftPickHTML do
  use Ex338Web, :html

  import Ex338Web.CoreComponents

  def edit(assigns) do
    ~H"""
    <.two_col_form
      :let={f}
      id="js-confirm-submit"
      for={@changeset}
      action={~p"/in_season_draft_picks/#{@in_season_draft_pick}"}
    >
      <:title>
        Submit <%= @in_season_draft_pick.championship.title %> Draft Pick
      </:title>
      <:description>
        Please make a selection for <%= @in_season_draft_pick.draft_pick_asset.fantasy_team.team_name %>'s
        round <%= @in_season_draft_pick.position %> pick.
      </:description>

      <.input
        field={f[:drafted_player_id]}
        label="Player to Draft"
        type="select"
        options={format_players_for_select(@fantasy_players)}
        prompt="Select a fantasy player"
      />

      <:actions>
        <.submit_buttons back_route={
          ~p"/fantasy_leagues/#{@in_season_draft_pick.draft_pick_asset.fantasy_team.fantasy_league_id}/championships/#{@in_season_draft_pick.championship_id}"
        } />
      </:actions>
    </.two_col_form>
    """
  end
end
