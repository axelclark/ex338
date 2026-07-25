defmodule Ex338Web.Api.V1.DraftQueueController do
  use Ex338Web, :controller

  alias Ex338Web.ApiActions

  action_fallback Ex338Web.Api.V1.FallbackController

  def create(conn, %{"fantasy_team_id" => team_id, "draft_queue" => params}) do
    actor = %{user: conn.assigns.current_user, api_token: conn.assigns[:current_api_token]}

    with {:ok, draft_queue} <- ApiActions.create_draft_queue(actor, "api", team_id, params) do
      conn
      |> put_status(:created)
      |> render(:show, draft_queue: draft_queue)
    end
  end
end
