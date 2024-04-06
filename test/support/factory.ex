defmodule Ex338.Factory do
  @moduledoc """
  Defines factories for creating test data
  """

  use ExMachina.Ecto, repo: Ex338.Repo

  alias Ex338.Accounts.User
  alias Ex338.CalendarAssistant
  alias Ex338.Repo

  def championship_factory do
    %Ex338.Championships.Championship{
      title: sequence(:title, &"Championship ##{&1}"),
      sports_league: build(:sports_league),
      category: "overall",
      in_season_draft: false,
      max_draft_mins: 5,
      draft_starts_at: CalendarAssistant.mins_from_now(-4),
      trade_deadline_at: CalendarAssistant.days_from_now(30),
      waiver_deadline_at: CalendarAssistant.days_from_now(30),
      championship_at: CalendarAssistant.days_from_now(60),
      year: 2017
    }
  end

  def champ_with_events_result_factory do
    %Ex338.Championships.ChampWithEventsResult{
      points: 8.0,
      rank: 1,
      winnings: 25.00,
      fantasy_team: build(:fantasy_team),
      championship: build(:championship)
    }
  end

  def championship_result_factory do
    %Ex338.Championships.ChampionshipResult{
      points: 8,
      rank: 1,
      fantasy_player: build(:fantasy_player),
      championship: build(:championship)
    }
  end

  def championship_slot_factory do
    %Ex338.Championships.ChampionshipSlot{
      slot: 1,
      roster_position: build(:roster_position),
      championship: build(:championship)
    }
  end

  def chat_factory do
    room_name = sequence(:title, &"Room (#{&1})")

    %Ex338.Chats.Chat{
      room_name: room_name
    }
  end

  def draft_pick_factory do
    %Ex338.DraftPicks.DraftPick{
      draft_position: 1.01,
      fantasy_league: build(:fantasy_league),
      fantasy_team: build(:fantasy_team)
    }
  end

  def submitted_pick_factory do
    %Ex338.DraftPicks.DraftPick{
      draft_position: 1.01,
      fantasy_league: build(:fantasy_league),
      fantasy_team: build(:fantasy_team),
      fantasy_player: build(:fantasy_player)
    }
  end

  def draft_queue_factory do
    %Ex338.DraftQueues.DraftQueue{
      fantasy_team: build(:fantasy_team),
      order: 1,
      fantasy_player: build(:fantasy_player)
    }
  end

  def fantasy_league_factory do
    %Ex338.FantasyLeagues.FantasyLeague{
      fantasy_league_name: sequence(:division, &"Div#{&1}"),
      division: sequence(:division, &"Div#{&1}"),
      year: 2017,
      championships_start_at: CalendarAssistant.days_from_now(-180),
      championships_end_at: CalendarAssistant.days_from_now(180),
      max_draft_hours: 0,
      max_flex_spots: 6,
      draft_method: "redraft"
    }
  end

  def fantasy_league_draft_factory do
    %Ex338.FantasyLeagues.FantasyLeagueDraft{
      fantasy_league: build(:fantasy_league),
      chat: build(:chat)
    }
  end

  def fantasy_player_factory do
    %Ex338.FantasyPlayers.FantasyPlayer{
      player_name: sequence(:player_name, &"Player ##{&1}"),
      draft_pick: false,
      available_starting_at: CalendarAssistant.days_from_now(-365),
      sports_league: build(:sports_league)
    }
  end

  def fantasy_team_factory do
    %Ex338.FantasyTeams.FantasyTeam{
      team_name: sequence(:team_name, &"Team ##{&1}"),
      fantasy_league: build(:fantasy_league),
      waiver_position: 1,
      autodraft_setting: "on"
    }
  end

  def future_pick_factory do
    %Ex338.DraftPicks.FuturePick{
      round: 1,
      current_team: build(:fantasy_team),
      original_team: build(:fantasy_team)
    }
  end

  def historical_record_factory do
    %Ex338.FantasyLeagues.HistoricalRecord{
      team: sequence(:team_name, &"Team ##{&1}"),
      record: "13",
      description: "Championships",
      type: "all_time"
    }
  end

  def historical_winning_factory do
    %Ex338.FantasyLeagues.HistoricalWinning{
      team: sequence(:team_name, &"Team ##{&1}"),
      amount: 0
    }
  end

  def in_season_draft_pick_factory do
    %Ex338.InSeasonDraftPicks.InSeasonDraftPick{
      position: 1,
      fantasy_league: build(:fantasy_league),
      draft_pick_asset: build(:roster_position),
      championship: build(:championship)
    }
  end

  def injured_reserve_factory do
    %Ex338.InjuredReserves.InjuredReserve{
      fantasy_team: build(:fantasy_team),
      injured_player: build(:fantasy_player),
      replacement_player: build(:fantasy_player),
      status: "submitted"
    }
  end

  def league_sport_factory do
    %Ex338.FantasyLeagues.LeagueSport{
      fantasy_league: build(:fantasy_league),
      sports_league: build(:sports_league)
    }
  end

  def message_factory do
    %Ex338.Chats.Message{
      content: "This is a test message",
      chat: build(:chat)
    }
  end

  def owner_factory do
    %Ex338.FantasyTeams.Owner{
      fantasy_team: build(:fantasy_team),
      user: build(:user),
      rules: "unaccepted"
    }
  end

  def roster_position_factory do
    %Ex338.RosterPositions.RosterPosition{
      active_at: CalendarAssistant.days_from_now(-10),
      acq_method: "unknown",
      fantasy_team: build(:fantasy_team),
      fantasy_player: build(:fantasy_player),
      position: "Unassigned",
      released_at: nil
    }
  end

  def trade_factory do
    %Ex338.Trades.Trade{
      status: "Pending"
    }
  end

  def trade_line_item_factory do
    %Ex338.Trades.TradeLineItem{
      trade: build(:trade),
      gaining_team: build(:fantasy_team),
      losing_team: build(:fantasy_team)
    }
  end

  def trade_vote_factory do
    %Ex338.Trades.TradeVote{
      trade: build(:trade),
      fantasy_team: build(:fantasy_team),
      user: build(:user),
      approve: true
    }
  end

  def sports_league_factory do
    %Ex338.FantasyPlayers.SportsLeague{
      league_name: sequence(:league_name, &"League ##{&1}"),
      abbrev: sequence(:abbrev, &"L#{&1}"),
      hide_waivers: false
    }
  end

  def user_factory do
    %Ex338.Accounts.User{
      name: "Some User",
      email: "user#{Base.encode16(:crypto.strong_rand_bytes(8))}@example.com",
      password: "secret",
      admin: false
    }
  end

  def insert_user(attrs \\ %{}) do
    changes =
      Map.merge(
        %{
          name: "Some User",
          email: "user#{Base.encode16(:crypto.strong_rand_bytes(8))}@example.com",
          password: "secret",
          confirm_password: "secret",
          admin: false
        },
        attrs
      )

    %User{}
    |> User.changeset(changes)
    |> Repo.insert!()
  end

  def insert_admin(attrs \\ %{}) do
    changes =
      Map.merge(
        %{
          name: "Some User",
          email: "user#{Base.encode16(:crypto.strong_rand_bytes(8))}@example.com",
          password: "secret",
          confirm_password: "secret",
          admin: true
        },
        attrs
      )

    %User{}
    |> User.changeset(changes)
    |> Repo.insert!()
  end

  def waiver_factory do
    %Ex338.Waivers.Waiver{
      fantasy_team: build(:fantasy_team),
      add_fantasy_player: build(:fantasy_player),
      drop_fantasy_player: build(:fantasy_player),
      process_at: DateTime.utc_now()
    }
  end
end
