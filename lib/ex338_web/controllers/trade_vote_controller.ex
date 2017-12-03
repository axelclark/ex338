defmodule Ex338Web.TradeVoteController do
  use Ex338Web, :controller

  alias Ex338.{FantasyTeam, TradeVote}
  alias Ex338Web.{Authorization}

  plug :load_and_authorize_resource, model: FantasyTeam, only: [:create],
    preload: [:owners, :fantasy_league], persisted: true,
    id_name: "fantasy_team_id",
    unauthorized_handler: {Authorization, :handle_unauthorized}

  import Canary.Plugs

  def create(conn, %{"fantasy_team_id" => _id, "trade_vote" => vote_params}) do
    team = conn.assigns.fantasy_team

    vote_params =
      vote_params
      |> Map.put("user_id", conn.assigns.current_user.id)
      |> Map.put("fantasy_team_id", team.id)

    case TradeVote.Store.create_vote(vote_params) do
      {:ok, _vote} ->

        conn
        |> put_flash(:info, "Vote successfully submitted.")
        |> redirect(to: fantasy_league_trade_path(
             conn, :index, team.fantasy_league_id
           ))

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "There was an error with your vote.")
        |> redirect(to: fantasy_league_trade_path(
             conn, :index, team.fantasy_league_id
           ))
    end
  end
end

