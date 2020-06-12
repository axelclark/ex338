defmodule Ex338Web.LoadLeagues do
  @moduledoc """
  Loads all fantasy leagues into conn assigns for use in header
  """

  import Plug.Conn

  alias Ex338.{FantasyLeagues}

  def init(options) do
    # initialize options

    options
  end

  def call(conn, _opts) do
    leagues = FantasyLeagues.list_fantasy_leagues()
    assign(conn, :leagues, leagues)
  end
end
