defmodule Ex338.InSeasonDraftPicksTest do
  use Ex338.DataCase, async: true
  use Oban.Testing, repo: Ex338.Repo

  alias Ex338.{
    CalendarAssistant,
    DraftQueues.DraftQueue,
    InSeasonDraftPicks,
    InSeasonDraftPicks.InSeasonDraftPick
  }

  describe "pick_with_assocs/1" do
    test "returns in season draft picks with associations" do
      player = insert(:fantasy_player, draft_pick: false)
      pick = insert(:in_season_draft_pick, drafted_player: player)

      %{
        id: id,
        draft_pick_asset: %{fantasy_team: %{}, fantasy_player: %{}},
        drafted_player: %{id: _drafted_player_id},
        championship: %{id: _championship_id}
      } = InSeasonDraftPicks.pick_with_assocs(pick.id)

      assert id == pick.id
    end
  end

  describe "owner_changeset/1" do
    test "returns changeset for owner update" do
      pick = insert(:in_season_draft_pick)

      changeset = InSeasonDraftPicks.changeset(pick)

      assert changeset.valid?
    end
  end

  describe "available_players/1" do
    test "returns available players to draft" do
      league = insert(:fantasy_league)
      league_b = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      team_b = insert(:fantasy_team, fantasy_league: league_b)

      sport = insert(:sports_league)
      champ = insert(:championship, sports_league: sport)

      insert(:league_sport, fantasy_league: league, sports_league: sport)
      insert(:league_sport, fantasy_league: league_b, sports_league: sport)

      pick_player = insert(:fantasy_player, draft_pick: true, sports_league: sport)
      pick_asset = insert(:roster_position, fantasy_team: team, fantasy_player: pick_player)

      pick =
        insert(
          :in_season_draft_pick,
          position: 1,
          draft_pick_asset: pick_asset,
          championship: champ
        )

      drafted_player = insert(:fantasy_player, draft_pick: false, sports_league: sport)
      insert(:roster_position, fantasy_team: team, fantasy_player: drafted_player)
      avail_player = insert(:fantasy_player, draft_pick: false, sports_league: sport)
      insert(:roster_position, fantasy_team: team_b, fantasy_player: avail_player)

      pick = InSeasonDraftPicks.pick_with_assocs(pick.id)
      [result] = InSeasonDraftPicks.available_players(pick)

      assert result.id == avail_player.id
    end
  end

  describe "by_league_and_sport/2" do
    test "returns picks in descending order for a league and sport" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      sport_a = insert(:sports_league)
      sport_b = insert(:sports_league)
      championship_a = insert(:championship, sports_league: sport_a)
      championship_b = insert(:championship, sports_league: sport_b)

      pick = insert(:fantasy_player, sports_league: sport_a)
      pick_asset = insert(:roster_position, fantasy_team: team, fantasy_player: pick)
      player = insert(:fantasy_player, sports_league: sport_a)

      insert(
        :in_season_draft_pick,
        position: 1,
        draft_pick_asset: pick_asset,
        drafted_player: player,
        championship: championship_a
      )

      insert(
        :in_season_draft_pick,
        position: 3,
        draft_pick_asset: pick_asset,
        championship: championship_a
      )

      insert(
        :in_season_draft_pick,
        position: 2,
        draft_pick_asset: pick_asset,
        championship: championship_a
      )

      other_pick = insert(:fantasy_player, sports_league: sport_b)
      other_asset = insert(:roster_position, fantasy_team: team, fantasy_player: other_pick)

      insert(
        :in_season_draft_pick,
        position: 2,
        draft_pick_asset: other_asset,
        championship: championship_b
      )

      result =
        league.id
        |> InSeasonDraftPicks.by_league_and_sport(sport_a.id)
        |> Enum.map(& &1.position)

      assert result == [1, 2, 3]
    end
  end

  describe "draft_player/2" do
    test "updates a in season draft pick with a fantasy player" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)

      sport = insert(:sports_league, abbrev: "KD")
      championship = insert(:championship, sports_league: sport)
      pick_player = insert(:fantasy_player, draft_pick: true, sports_league: sport)
      player = insert(:fantasy_player, draft_pick: false, sports_league: sport)
      pick_asset = insert(:roster_position, fantasy_team: team, fantasy_player: pick_player)

      pick =
        insert(
          :in_season_draft_pick,
          position: 1,
          draft_pick_asset: pick_asset,
          championship: championship
        )

      q1 = insert(:draft_queue, fantasy_team: team, fantasy_player: player)
      params = %{"drafted_player_id" => player.id}

      team2 = insert(:fantasy_team, fantasy_league: league)
      q2 = insert(:draft_queue, fantasy_team: team2, fantasy_player: player)

      {
        :ok,
        %{
          update_pick: updated_pick,
          update_position: old_pos,
          new_position: new_pos,
          unavailable_draft_queues: {1, nil},
          drafted_draft_queues: {1, nil}
        }
      } = InSeasonDraftPicks.draft_player(pick, params)

      drafted_queue = Repo.get!(DraftQueue, q1.id)
      updated_queue = Repo.get!(DraftQueue, q2.id)

      assert updated_pick.drafted_player_id == player.id
      assert old_pos.status == "drafted_pick"
      assert old_pos.released_at !== nil
      assert new_pos.fantasy_team_id == team.id
      assert new_pos.fantasy_player_id == player.id
      assert new_pos.position == pick_asset.position
      assert new_pos.status == "active"
      assert new_pos.acq_method == "KD Draft:1"
      assert updated_queue.status == :unavailable
      assert drafted_queue.status == :drafted
    end

    test "does not update and returns errors when invalid" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)

      championship = insert(:championship)
      pick_player = insert(:fantasy_player, draft_pick: true)
      pick_asset = insert(:roster_position, fantasy_team: team, fantasy_player: pick_player)

      pick =
        insert(
          :in_season_draft_pick,
          position: 1,
          draft_pick_asset: pick_asset,
          championship: championship
        )

      params = %{"drafted_player_id" => ""}

      {:error, :update_pick, changeset, _} = InSeasonDraftPicks.draft_player(pick, params)

      assert changeset.errors == [drafted_player_id: {"can't be blank", [validation: :required]}]
    end
  end

  describe "next_picks/2" do
    test "returns next specified number of picks in descending order" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      sport_a = insert(:sports_league)
      sport_b = insert(:sports_league)
      championship_a = insert(:championship, sports_league: sport_a)
      championship_b = insert(:championship, sports_league: sport_b)

      pick = insert(:fantasy_player, sports_league: sport_a)
      pick_asset = insert(:roster_position, fantasy_team: team, fantasy_player: pick)
      player = insert(:fantasy_player, sports_league: sport_a)

      insert(
        :in_season_draft_pick,
        position: 1,
        draft_pick_asset: pick_asset,
        drafted_player: player,
        championship: championship_a
      )

      insert(
        :in_season_draft_pick,
        position: 3,
        draft_pick_asset: pick_asset,
        championship: championship_a
      )

      insert(
        :in_season_draft_pick,
        position: 2,
        draft_pick_asset: pick_asset,
        championship: championship_a
      )

      insert(
        :in_season_draft_pick,
        position: 4,
        draft_pick_asset: pick_asset,
        championship: championship_a
      )

      insert(
        :in_season_draft_pick,
        position: 5,
        draft_pick_asset: pick_asset,
        championship: championship_a
      )

      insert(
        :in_season_draft_pick,
        position: 6,
        draft_pick_asset: pick_asset,
        championship: championship_a
      )

      insert(
        :in_season_draft_pick,
        position: 7,
        draft_pick_asset: pick_asset,
        championship: championship_a
      )

      other_pick = insert(:fantasy_player, sports_league: sport_b)
      other_asset = insert(:roster_position, fantasy_team: team, fantasy_player: other_pick)

      insert(
        :in_season_draft_pick,
        position: 2,
        draft_pick_asset: other_asset,
        championship: championship_b
      )

      result =
        league.id
        |> InSeasonDraftPicks.next_picks(sport_a.id, 5)
        |> Enum.map(& &1.position)

      assert result == [2, 3, 4, 5, 6]
    end
  end

  describe "last_picks/2" do
    test "returns last specified number of picks in ascending order" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      sport_a = insert(:sports_league)
      sport_b = insert(:sports_league)
      championship_a = insert(:championship, sports_league: sport_a)
      championship_b = insert(:championship, sports_league: sport_b)

      pick = insert(:fantasy_player, sports_league: sport_a)
      pick_asset = insert(:roster_position, fantasy_team: team, fantasy_player: pick)
      player = insert(:fantasy_player, sports_league: sport_a)

      insert(
        :in_season_draft_pick,
        position: 2,
        draft_pick_asset: pick_asset,
        drafted_player: player,
        championship: championship_a
      )

      insert(
        :in_season_draft_pick,
        position: 1,
        draft_pick_asset: pick_asset,
        drafted_player: player,
        championship: championship_a
      )

      insert(
        :in_season_draft_pick,
        position: 3,
        draft_pick_asset: pick_asset,
        drafted_player: player,
        championship: championship_a
      )

      insert(
        :in_season_draft_pick,
        position: 4,
        draft_pick_asset: pick_asset,
        drafted_player: player,
        championship: championship_a
      )

      insert(
        :in_season_draft_pick,
        position: 5,
        draft_pick_asset: pick_asset,
        championship: championship_a
      )

      other_pick = insert(:fantasy_player, sports_league: sport_b)
      other_player = insert(:fantasy_player, sports_league: sport_b)
      other_asset = insert(:roster_position, fantasy_team: team, fantasy_player: other_pick)

      insert(
        :in_season_draft_pick,
        position: 3,
        draft_pick_asset: other_asset,
        championship: championship_b,
        drafted_player: other_player
      )

      result =
        league.id
        |> InSeasonDraftPicks.last_picks(sport_a.id, 3)
        |> Enum.map(& &1.position)

      assert result == [4, 3, 2]
    end
  end

  describe "create_picks_for_league/2" do
    test "creates draft picks for roster positions in a league" do
      league = insert(:fantasy_league)
      team_a = insert(:fantasy_team, fantasy_league: league)
      team_b = insert(:fantasy_team, fantasy_league: league)

      sport = insert(:sports_league)
      championship = insert(:championship, category: "overall", sports_league: sport)

      player_1 =
        insert(:fantasy_player, player_name: "KD Pick #1", sports_league: sport, draft_pick: true)

      player_2 =
        insert(:fantasy_player, player_name: "KD Pick #2", sports_league: sport, draft_pick: true)

      player_3 =
        insert(:fantasy_player, player_name: "KD Pick #3", sports_league: sport, draft_pick: true)

      pos1 = insert(:roster_position, fantasy_player: player_1, fantasy_team: team_a)
      pos2 = insert(:roster_position, fantasy_player: player_2, fantasy_team: team_b)
      pos3 = insert(:roster_position, fantasy_player: player_3, fantasy_team: team_a)

      InSeasonDraftPicks.create_picks_for_league(league.id, championship.id)

      new_picks =
        InSeasonDraftPick
        |> InSeasonDraftPick.draft_order()
        |> Repo.all()

      assert Enum.map(new_picks, & &1.position) == [1, 2, 3]
      assert Enum.map(new_picks, & &1.draft_pick_asset_id) == [pos1.id, pos2.id, pos3.id]
    end

    test "creates draft picks for roster positions in FKD sports league" do
      league = insert(:fantasy_league)
      team_a = insert(:fantasy_team, fantasy_league: league)
      team_b = insert(:fantasy_team, fantasy_league: league)

      sport = insert(:sports_league, abbrev: "FKD")
      championship = insert(:championship, category: "overall", sports_league: sport)

      player_1 =
        insert(:fantasy_player,
          player_name: "Fall KD Pick #01",
          sports_league: sport,
          draft_pick: true
        )

      player_2 =
        insert(:fantasy_player,
          player_name: "Fall KD Pick #02",
          sports_league: sport,
          draft_pick: true
        )

      player_3 =
        insert(:fantasy_player,
          player_name: "Fall KD Pick #03",
          sports_league: sport,
          draft_pick: true
        )

      pos1 = insert(:roster_position, fantasy_player: player_1, fantasy_team: team_a)
      pos2 = insert(:roster_position, fantasy_player: player_2, fantasy_team: team_b)
      pos3 = insert(:roster_position, fantasy_player: player_3, fantasy_team: team_a)

      InSeasonDraftPicks.create_picks_for_league(league.id, championship.id)

      new_picks =
        InSeasonDraftPick
        |> InSeasonDraftPick.draft_order()
        |> Repo.all()

      assert Enum.map(new_picks, & &1.position) == [1, 2, 3]
      assert Enum.map(new_picks, & &1.draft_pick_asset_id) == [pos1.id, pos2.id, pos3.id]
    end

    test "handles error in multi" do
      league = insert(:fantasy_league)
      team_a = insert(:fantasy_team, fantasy_league: league)

      sport = insert(:sports_league)
      championship = insert(:championship, category: "overall", sports_league: sport)

      player_1 =
        insert(
          :fantasy_player,
          player_name: "Wrong Format",
          sports_league: sport,
          draft_pick: true
        )

      player_2 =
        insert(:fantasy_player, player_name: "Pick #2", sports_league: sport, draft_pick: true)

      insert(:roster_position, fantasy_player: player_1, fantasy_team: team_a)
      insert(:roster_position, fantasy_player: player_2, fantasy_team: team_a)

      {:error, _, changeset, _} =
        InSeasonDraftPicks.create_picks_for_league(league.id, championship.id)

      assert changeset.valid? == false
    end
  end

  describe "schedule_autodraft/2" do
    test "schedules in season autodraft for a fantasy league" do
      league = insert(:fantasy_league)
      sport = insert(:sports_league)

      championship =
        insert(:championship,
          sports_league: sport,
          max_draft_mins: 5,
          draft_starts_at: CalendarAssistant.mins_from_now(5)
        )

      {:ok, _result} =
        Oban.Testing.with_testing_mode(:manual, fn ->
          InSeasonDraftPicks.schedule_autodraft(league.id, championship)
        end)

      assert_enqueued(
        worker: Ex338.Workers.InSeasonAutodraftWorker,
        scheduled_at: championship.draft_starts_at
      )
    end

    test "immediately starts autodraft for a fantasy league" do
      league = insert(:fantasy_league)
      sport = insert(:sports_league)

      championship =
        insert(:championship,
          sports_league: sport,
          max_draft_mins: 5,
          draft_starts_at: CalendarAssistant.mins_from_now(-5)
        )

      {:ok, _result} =
        Oban.Testing.with_testing_mode(:manual, fn ->
          InSeasonDraftPicks.schedule_autodraft(league.id, championship)
        end)

      assert_enqueued(
        worker: Ex338.Workers.InSeasonAutodraftWorker,
        scheduled_at: DateTime.utc_now()
      )
    end
  end
end
