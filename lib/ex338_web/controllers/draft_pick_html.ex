defmodule Ex338Web.DraftPickHTML do
  use Ex338Web, :html

  def edit(assigns) do
    ~H"""
    <.two_col_form
      :let={f}
      id="js-confirm-submit"
      for={@changeset}
      action={~p"/draft_picks/#{@draft_pick}"}
    >
      <:title>
        Submit a new Draft Pick
      </:title>
      <:description>
        Please make a selection for <%= @draft_pick.fantasy_team.team_name %>'s <%= @draft_pick.draft_position %> draft pick.
      </:description>
      <.input
        field={f[:sports_league]}
        label="Sports League"
        type="select"
        options={sports_abbrevs(@fantasy_players)}
        class="sports-select-filter"
        prompt="Select sport to filter players"
      />

      <.input
        field={f[:fantasy_player_id]}
        label="Fantasy Player"
        type="select"
        options={format_players_for_select(@fantasy_players)}
        class="players-to-filter"
        prompt="Select player to draft"
      />

      <:actions>
        <.submit_buttons back_route={
          ~p"/fantasy_leagues/#{@draft_pick.fantasy_league_id}/draft_picks"
        } />
      </:actions>
    </.two_col_form>
    """
  end

  def index(assigns) do
    ~H"""
    <.page_header>
      Draft Picks for Division <%= @fantasy_league.division %>
    </.page_header>

    <%= live_render(
      @conn,
      Ex338Web.DraftPickLive,
      session: %{
        "current_user_id" => maybe_fetch_current_user_id(@current_user),
        "fantasy_league_id" => @fantasy_league.id
      }
    ) %>
    """
  end

  # used by draft emails
  def current_picks(draft_picks, amount) when amount >= 0 do
    next_pick_index = Enum.find_index(draft_picks, &(&1.fantasy_player_id == nil))
    get_current_picks(draft_picks, next_pick_index, amount)
  end

  def get_current_picks(draft_picks, nil, amount) do
    Enum.take(draft_picks, -div(amount, 2))
  end

  def get_current_picks(draft_picks, index, amount) do
    start_index = index - div(amount, 2)

    start_index =
      if start_index < 0 do
        0
      else
        start_index
      end

    Enum.slice(draft_picks, start_index, amount)
  end
end
