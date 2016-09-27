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
      waiver_position: 1,
    }
  end

  def owner_factory do
    %Ex338.Owner{
      fantasy_team:          build(:fantasy_team),
      user:                  insert_user,
    }
  end

  def sports_league_factory do
    %Ex338.SportsLeague{
      league_name: sequence(:league_name, &"League ##{&1}"),
      abbrev: sequence(:abbrev, &"L#{&1}"),
      trade_deadline: Ecto.DateTime.cast!(
        %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}
      ),
      waiver_deadline: Ecto.DateTime.cast!(
        %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}
      ),
      championship_date: Ecto.DateTime.cast!(
        %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}
      ),
   }
  end

  def championship_factory do
    %Ex338.Championship{
      title: sequence(:title, &"Championship ##{&1}"),
      sports_league: build(:sports_league),
      category: "overall",
      trade_deadline_at: Ecto.DateTime.cast!(
        %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}
      ),
      waiver_deadline_at: Ecto.DateTime.cast!(
        %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}
      ),
      championship_at: Ecto.DateTime.cast!(
        %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}
      ),
    }
  end

  def fantasy_player_factory do
    %Ex338.FantasyPlayer{
      player_name:  sequence(:player_name, &"Player ##{&1}"),
      sports_league: build(:sports_league),
    }
  end

  def roster_position_factory do
    %Ex338.RosterPosition{
      position: "Unassigned",
      fantasy_team:   build(:fantasy_team),
    }
  end

  def filled_roster_position_factory do
    %Ex338.RosterPosition{
      position: "Unassigned",
      fantasy_team:   build(:fantasy_team),
      fantasy_player:   build(:fantasy_player),
    }
  end

  def draft_pick_factory do
    %Ex338.DraftPick{
      draft_position: 1.01,
      fantasy_league:   build(:fantasy_league),
      fantasy_team:     build(:fantasy_team),
    }
  end

  def submitted_pick_factory do
    %Ex338.DraftPick{
      draft_position: 1.01,
      fantasy_league:   build(:fantasy_league),
      fantasy_team:     build(:fantasy_team),
      fantasy_player:   build(:fantasy_player),
    }
  end


  def waiver_factory do
    %Ex338.Waiver{
      fantasy_team:          build(:fantasy_team),
      add_fantasy_player:    build(:fantasy_player),
      drop_fantasy_player:   build(:fantasy_player),
    }
  end

  def trade_factory do
    %Ex338.Trade{
      status: "Approved",
    }
  end

  def trade_line_item_factory do
    %Ex338.TradeLineItem{
      action: "adds",
      trade:          build(:trade),
      fantasy_team:   build(:fantasy_team),
      fantasy_player: build(:fantasy_player),
    }
  end

  def insert_user(attrs \\ %{}) do
    changes = Dict.merge(%{
      name: "Some User",
      email: "user#{Base.encode16(:crypto.strong_rand_bytes(8))}@example.com",
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
      email: "user#{Base.encode16(:crypto.strong_rand_bytes(8))}@example.com",
      password: "secret",
      admin: true,
    }, attrs)

    %User{}
    |> User.changeset(changes)
    |> Repo.insert!
  end
end
