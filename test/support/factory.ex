defmodule Ex338.Factory do
  @moduledoc """
  Defines factories for creating test data
  """

  use ExMachina.Ecto, repo: Ex338.Repo

  alias Ex338.{User, Repo}

  def fantasy_league_factory do
    %Ex338.FantasyLeague{
      fantasy_league_name: sequence(:division, &"Div#{&1}"),
      division: sequence(:division, &"Div#{&1}"),
      year: 2017,
    }
  end

  def fantasy_team_factory do
    %Ex338.FantasyTeam{
      team_name: sequence(:team_name, &"Team ##{&1}"),
      fantasy_league: build(:fantasy_league),
    }
  end

  def sports_league_factory do
    %Ex338.SportsLeague{league_name: sequence(:league_name, &"League ##{&1}")}
  end

  def fantasy_player_factory do
    %Ex338.FantasyPlayer{
      player_name:  sequence(:player_name, &"Player ##{&1}"),
      sports_league: build(:sports_league),
    }
  end

  def roster_position_factory do
    %Ex338.RosterPosition{
      position: "Position",
      fantasy_team:   build(:fantasy_team),
    }
  end

  def draft_pick_factory do
    %Ex338.DraftPick{
      draft_position: 1.01,
      fantasy_league:   build(:fantasy_league),
      fantasy_team:   build(:fantasy_team),
    }
  end

  def waiver_factory do
    %Ex338.Waiver{
      status: "successful",
      fantasy_team:   build(:fantasy_team),
      add_fantasy_player:   build(:fantasy_player),
      drop_fantasy_player:   build(:fantasy_player),
    }
  end

  def roster_transaction_factory do
    %Ex338.RosterTransaction{
      category: "Waiver Claim",
      roster_transaction_on: date_time("2017-02-03T04:05:06Z"),
    }
  end

  def transaction_line_item_factory do
    %Ex338.TransactionLineItem{
      roster_transaction:   build(:roster_transaction),
      action: "adds",
      fantasy_team:   build(:fantasy_team),
      fantasy_player:   build(:fantasy_player),
    }
  end

  def insert_user(attrs \\ %{}) do
    changes = Dict.merge(%{
      name: "Some User",
      email: "test@example.com",
      password: "secret",
      admin: false,
    }, attrs)

    %User{}
    |> User.changeset(changes)
    |> Repo.insert!
  end

  def insert_admin(attrs \\ %{}) do
    changes = Dict.merge(%{
      name: "Some User",
      email: "test@example.com",
      password: "secret",
      admin: true,
    }, attrs)

    %User{}
    |> User.changeset(changes)
    |> Repo.insert!
  end



  defp date_time(date_time) do
    {:ok, cast_time} = Ecto.DateTime.cast(date_time)
    cast_time
  end
end
