defmodule Ex338Web.Api.V1.DraftPickController do
  use Ex338Web, :controller

  alias Ex338.DraftPicks
  alias Ex338Web.ApiActions

  action_fallback Ex338Web.Api.V1.FallbackController

  def index(conn, %{"fantasy_league_id" => league_id}) do
    %{draft_picks: draft_picks} = DraftPicks.get_picks_for_league(league_id)
    render(conn, :index, draft_picks: draft_picks)
  end

  @doc """
  Drafts a player with this pick — owners on their own team's picks, admins on any.
  """
  def draft_player(conn, %{"id" => id, "draft_pick" => draft_pick_params}) do
    with {:ok, draft_pick} <- ApiActions.draft_player(actor(conn), "api", id, draft_pick_params) do
      render(conn, :show, draft_pick: draft_pick)
    end
  end

  @doc """
  Corrects a draft pick's fields directly (admin only). See
  `Ex338Web.ApiActions.update_draft_pick/4` for what this does and does not touch.
  """
  def update(conn, %{"id" => id, "draft_pick" => draft_pick_params}) do
    with {:ok, draft_pick} <-
           ApiActions.update_draft_pick(actor(conn), "api", id, draft_pick_params) do
      render(conn, :show, draft_pick: draft_pick)
    end
  end

  defp actor(conn) do
    %{user: conn.assigns.current_user, api_token: conn.assigns[:current_api_token]}
  end
end
