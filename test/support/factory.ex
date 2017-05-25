defmodule Ex338.Factory do
  @moduledoc """
  Defines factories for creating test data
  """

  use ExMachina.Ecto, repo: Ex338.Repo

  alias Ex338.{User, Repo, CalendarAssistant}

  def championship_factory do
    %Ex338.Championship{
      title: sequence(:title, &"Championship ##{&1}"),
      sports_league: build(:sports_league),
      category: "overall",
      in_season_draft: false,
      trade_deadline_at: CalendarAssistant.days_from_now(30),
      waiver_deadline_at: CalendarAssistant.days_from_now(30),
      championship_at: CalendarAssistant.days_from_now(60),
      year: 2017
    }
  end

  def champ_with_events_result_factory do
    %Ex338.ChampWithEventsResult{
      points: 8.0,
      rank:   1,
      winnings:   25.00,
      fantasy_team: build(:fantasy_team),
      championship:   build(:championship)
    }
  end

  def championship_result_factory do
    %Ex338.ChampionshipResult{
      points: 8,
      rank:   1,
      fantasy_player: build(:fantasy_player),
      championship:   build(:championship)
    }
  end

  def championship_slot_factory do
    %Ex338.ChampionshipSlot{
      slot:   1,
      roster_position: build(:roster_position),
      championship:   build(:championship)
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

  def fantasy_league_factory do
    %Ex338.FantasyLeague{
      fantasy_league_name: sequence(:division, &"Div#{&1}"),
      division: sequence(:division, &"Div#{&1}"),
      year: 2017,
    }
  end

  def fantasy_player_factory do
    %Ex338.FantasyPlayer{
      player_name:   sequence(:player_name, &"Player ##{&1}"),
      draft_pick: false,
      sports_league: build(:sports_league),
    }
  end

  def fantasy_team_factory do
    %Ex338.FantasyTeam{
      team_name: sequence(:team_name, &"Team ##{&1}"),
      fantasy_league: build(:fantasy_league),
      waiver_position: 1,
    }
  end

  def in_season_draft_pick_factory do
    %Ex338.InSeasonDraftPick{
      position: 1,
      draft_pick_asset: build(:roster_position),
      championship: build(:championship),
    }
  end

  def injured_reserve_factory do
    %Ex338.InjuredReserve{
      fantasy_team: build(:fantasy_team),
      status:       "pending"
    }
  end

  def add_replace_injured_reserve_factory do
    %Ex338.InjuredReserve{
      fantasy_team:          build(:fantasy_team),
      add_player:            build(:fantasy_player),
      replacement_player:    build(:fantasy_player),
      status:                "pending"
    }
  end

  def league_sport_factory do
    %Ex338.LeagueSport{
      fantasy_league: build(:fantasy_league),
      sports_league: build(:sports_league)
    }
  end

  def owner_factory do
    %Ex338.Owner{
      fantasy_team: build(:fantasy_team),
      user:         insert_user(),
    }
  end

  def roster_position_factory do
    %Ex338.RosterPosition{
      position:       "Unassigned",
      fantasy_team:   build(:fantasy_team),
      fantasy_player:   build(:fantasy_player),
      active_at: CalendarAssistant.days_from_now(-10),
      released_at: nil
    }
  end

  def trade_factory do
    %Ex338.Trade{
      status: "Approved",
    }
  end

  def trade_line_item_factory do
    %Ex338.TradeLineItem{
      trade:          build(:trade),
      fantasy_player: build(:fantasy_player),
      gaining_team:   build(:fantasy_team),
      losing_team:    build(:fantasy_team),
    }
  end

  def sports_league_factory do
    %Ex338.SportsLeague{
      league_name: sequence(:league_name, &"League ##{&1}"),
      abbrev:      sequence(:abbrev, &"L#{&1}"),
      hide_waivers: false,
   }
  end

  def insert_user(attrs \\ %{}) do
    changes = Map.merge(%{
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
    changes = Map.merge(%{
      name: "Some User",
      email: "user#{Base.encode16(:crypto.strong_rand_bytes(8))}@example.com",
      password: "secret",
      admin: true,
    }, attrs)

    %User{}
    |> User.changeset(changes)
    |> Repo.insert!
  end

  def waiver_factory do
    %Ex338.Waiver{
      fantasy_team:          build(:fantasy_team),
      add_fantasy_player:    build(:fantasy_player),
      drop_fantasy_player:   build(:fantasy_player),
      process_at: Ecto.DateTime.utc,
    }
  end
end
