defmodule Ex338.FantasyTeams.FantasyTeam do
  @moduledoc false

  use Ex338Web, :model

  alias Ex338.{
    ChampionshipResult,
    ChampWithEventsResult,
    DraftQueue,
    FantasyLeagues.FantasyLeague,
    FantasyPlayers.SportsLeague,
    FantasyTeams.FantasyTeam,
    RosterPositions.RosterPosition
  }

  schema "fantasy_teams" do
    field(:team_name, :string)
    field(:waiver_position, :integer)
    field(:winnings_adj, :float, default: 0.0)
    field(:dues_paid, :float, default: 0.0)
    field(:winnings_received, :float, default: 0.0)
    field(:max_flex_adj, :integer, default: 0)
    field(:commish_notes, :string)
    field(:autodraft_setting, FantasyTeamAutodraftSettingEnum, default: "on")
    field(:slot_results, {:array, :map}, virtual: true, default: [])
    field(:total_seconds_on_the_clock, :integer, virtual: true, default: 0)
    field(:avg_seconds_on_the_clock, :integer, virtual: true, default: 0)
    field(:total_draft_mins_adj, :integer, default: 0)
    field(:picks_selected, :integer, virtual: true, default: 0)
    field(:over_draft_time_limit?, :boolean, virtual: true, default: false)
    belongs_to(:fantasy_league, Ex338.FantasyLeagues.FantasyLeague)
    has_many(:champ_with_events_results, Ex338.ChampWithEventsResult)
    has_many(:draft_picks, Ex338.DraftPick)
    has_many(:draft_queues, Ex338.DraftQueue)
    has_many(:future_picks, Ex338.DraftPicks.FuturePick, foreign_key: :current_team_id)
    has_many(:injured_reserves, Ex338.InjuredReserves.InjuredReserve)
    has_many(:owners, Ex338.FantasyTeams.Owner)
    has_many(:original_future_picks, Ex338.DraftPicks.FuturePick, foreign_key: :original_team_id)
    has_many(:roster_positions, Ex338.RosterPositions.RosterPosition)
    has_many(:submitted_trades, Ex338.Trades.Trade, foreign_key: :submitted_by_team_id)
    has_many(:trade_gains, Ex338.Trades.TradeLineItem, foreign_key: :gaining_team_id)
    has_many(:trade_losses, Ex338.Trades.TradeLineItem, foreign_key: :losing_team_id)
    has_many(:trade_votes, Ex338.Trades.TradeVote)
    has_many(:waivers, Ex338.Waivers.Waiver)
    has_many(:fantasy_players, through: [:roster_positions, :fantasy_player])
    has_many(:users, through: [:owners, :user])

    timestamps()
  end

  def alphabetical(query) do
    from(t in query, order_by: t.team_name)
  end

  def add_rankings_to_slot_results(slot_results) do
    slot_results
    |> Enum.group_by(& &1.sport_abbrev)
    |> Enum.map(&calculate_rankings(&1))
    |> Enum.reduce([], fn sport_slots, all_slots -> all_slots ++ sport_slots end)
  end

  def add_slot_results(slot_results, teams) when is_list(teams) do
    Enum.map(teams, &add_slot_results(slot_results, &1))
  end

  def add_slot_results(slot_results, %FantasyTeam{} = team) do
    Enum.reduce(slot_results, team, &do_add_slot_results(&2, &1))
  end

  def autodraft_setting_options() do
    [
      [key: "On", value: "on"],
      [key: "Off", value: "off"],
      [key: "Make Pick & Pause", value: "single"]
    ]
  end

  def by_league(query, league_id) do
    from(t in query, where: t.fantasy_league_id == ^league_id)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :autodraft_setting,
      :commish_notes,
      :dues_paid,
      :fantasy_league_id,
      :max_flex_adj,
      :team_name,
      :total_draft_mins_adj,
      :waiver_position,
      :winnings_adj,
      :winnings_received
    ])
    |> validate_required([:team_name, :waiver_position])
    |> validate_length(:team_name, max: 16)
    |> foreign_key_constraint(:fantasy_league_id)
  end

  def count_pending_draft_queues(query, team_id) do
    from(
      t in query,
      inner_join: q in assoc(t, :draft_queues),
      where: q.status == "pending",
      where: t.id == ^team_id,
      select: count(q.id)
    )
  end

  def find_team(query, id) do
    from(t in query, where: t.id == ^id)
  end

  def owner_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:team_name, :autodraft_setting])
    |> validate_required([:team_name])
    |> cast_assoc(:roster_positions)
    |> cast_assoc(:draft_queues)
    |> validate_length(:team_name, max: 16)
  end

  def order_by_waiver_position(query) do
    from(t in query, order_by: t.waiver_position)
  end

  def owned_players(query) do
    from(
      t in query,
      inner_join: r in assoc(t, :roster_positions),
      inner_join: p in assoc(r, :fantasy_player),
      inner_join: s in assoc(p, :sports_league),
      where: r.status == "active",
      select: %{
        player_name: p.player_name,
        league_abbrev: s.abbrev,
        id: p.id,
        fantasy_team_id: t.id
      },
      order_by: [s.abbrev, p.player_name]
    )
  end

  def preload_active_positions_for_sport(query, sports_league_id) do
    positions = RosterPosition.active_by_sports_league(RosterPosition, sports_league_id)

    from(t in query, preload: [roster_positions: ^positions])
  end

  def preload_all_active_positions(query) do
    positions =
      RosterPosition
      |> RosterPosition.all_active()
      |> RosterPosition.preload_assocs()

    from(t in query, preload: [roster_positions: ^positions])
  end

  def preload_assocs_by_league(query, fantasy_league) do
    %{
      id: league_id,
      championships_start_at: start_datetime,
      championships_end_at: end_datetime
    } = fantasy_league

    champ_results =
      ChampionshipResult.overall_from_range(ChampionshipResult, start_datetime, end_datetime)

    champ_with_events = ChampWithEventsResult.preload_assocs(ChampWithEventsResult)

    do_preload_assocs_by_league(query, league_id, champ_results, champ_with_events)
  end

  def preload_assocs_by_league_and_date(
        query,
        %FantasyLeague{id: league_id},
        datetime
      ) do
    champ_results = ChampionshipResult.overall_before_date_in_year(ChampionshipResult, datetime)
    champ_with_events = ChampWithEventsResult.before_date_in_year(ChampWithEventsResult, datetime)

    do_preload_assocs_by_league(query, league_id, champ_results, champ_with_events)
  end

  def sort_alphabetical(teams) do
    Enum.sort(teams, &(&1.team_name <= &2.team_name))
  end

  def sort_queues_by_order(%FantasyTeam{draft_queues: queues} = team_struct) do
    ordered_queues = Enum.sort(queues, &(&1.order <= &2.order))

    Map.put(team_struct, :draft_queues, ordered_queues)
  end

  def sum_slot_points(query) do
    from(
      t in query,
      join: r in assoc(t, :roster_positions),
      join: cs in assoc(r, :championship_slots),
      join: p in assoc(r, :fantasy_player),
      join: cr in assoc(p, :championship_results),
      join: c in assoc(cr, :championship),
      join: s in assoc(c, :sports_league),
      where: cs.championship_id == cr.championship_id,
      where: r.active_at < c.championship_at,
      where: r.released_at > c.championship_at or is_nil(r.released_at),
      order_by: [t.id, s.abbrev, cs.slot],
      group_by: [t.id, s.abbrev, cs.slot],
      select: %{
        slot: cs.slot,
        fantasy_team_id: t.id,
        sport_abbrev: s.abbrev,
        points: sum(cr.points)
      }
    )
  end

  def update_league_waiver_positions(query, %FantasyTeam{
        waiver_position: position,
        fantasy_league_id: league_id
      }) do
    from(
      f in query,
      where: f.waiver_position > ^position,
      where: f.fantasy_league_id == ^league_id,
      update: [inc: [waiver_position: -1]]
    )
  end

  def with_league(query) do
    from(f in query, preload: [:fantasy_league])
  end

  def without_player_from_sport(query, sport_id) do
    roster_subquery =
      RosterPosition
      |> RosterPosition.by_sports_league(sport_id)
      |> RosterPosition.all_owned()

    from(
      t in query,
      left_join: r in subquery(roster_subquery),
      on: r.fantasy_team_id == t.id,
      where: is_nil(r.id)
    )
  end

  ## Helpers

  defp do_preload_assocs_by_league(query, league_id, get_champ_results, get_champ_with_events) do
    sport_with_assocs = SportsLeague.preload_league_overall_championships(SportsLeague, league_id)

    from(
      t in query,
      left_join: r in RosterPosition,
      on: r.fantasy_team_id == t.id and (r.status == "active" or r.status == "injured_reserve"),
      left_join: p in assoc(r, :fantasy_player),
      preload: [
        roster_positions:
          {r,
           [
             fantasy_player: {
               p,
               [
                 sports_league: ^sport_with_assocs,
                 championship_results: ^get_champ_results
               ]
             }
           ]}
      ],
      left_join: q in DraftQueue,
      on: q.fantasy_team_id == t.id and q.status == "pending",
      left_join: qp in assoc(q, :fantasy_player),
      preload: [
        draft_queues:
          {q,
           [
             :fantasy_team,
             fantasy_player: {
               qp,
               [:sports_league]
             }
           ]}
      ],
      preload: [
        [owners: :user],
        [future_picks: :original_team],
        :fantasy_league,
        [champ_with_events_results: ^get_champ_with_events]
      ]
    )
  end

  ## add_rankings_to_slot_results

  defp calculate_rankings({_sport_abbrev, slot_results}) do
    slot_results
    |> sort_slots_by_points
    |> add_rank_to_slots
  end

  defp sort_slots_by_points(slot_results) do
    Enum.sort(slot_results, &(&1.points >= &2.points))
  end

  defp add_rank_to_slots(slot_results) do
    {teams, _} = Enum.map_reduce(slot_results, 1, &add_rank_to_slot/2)

    teams
  end

  defp add_rank_to_slot(%{points: points} = slot, rank) when points > 0 do
    {Map.put(slot, :rank, rank), rank + 1}
  end

  defp add_rank_to_slot(slot, rank) do
    {Map.put(slot, :rank, "-"), rank + 1}
  end

  ## add_slot_results

  defp do_add_slot_results(
         %FantasyTeam{id: id} = team,
         %{fantasy_team_id: id} = new_slot_result
       ) do
    new_slot_results = team.slot_results ++ [new_slot_result]
    %{team | slot_results: new_slot_results}
  end

  defp do_add_slot_results(team, _), do: team
end
