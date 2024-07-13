defmodule Ex338.DraftPicksTest do
  use Ex338.DataCase, async: true

  alias Ex338.DraftPicks
  alias Ex338.DraftPicks.FuturePick
  alias Ex338.DraftQueues.DraftQueue

  describe "future_picks" do
    @invalid_attrs %{round: nil}

    test "change_future_pick/1 returns a future_pick changeset" do
      future_pick = insert(:future_pick)
      assert %Ecto.Changeset{} = DraftPicks.change_future_pick(future_pick)
    end

    test "create_future_pick/1 with valid data creates a future_pick" do
      team = insert(:fantasy_team)
      attrs = %{round: 42, original_team_id: team.id, current_team_id: team.id}
      assert {:ok, %FuturePick{} = result} = DraftPicks.create_future_pick(attrs)
      assert result.round == 42
    end

    test "create_future_pick/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = DraftPicks.create_future_pick(@invalid_attrs)
    end

    test "create_future_picks/2 create future picks for teams" do
      teams = insert_list(3, :fantasy_team)
      picks = 2

      results = DraftPicks.create_future_picks(teams, picks)

      assert Enum.map(results, & &1.round) == [1, 1, 1, 2, 2, 2]
    end

    test "get_future_pick!/1 returns the future_pick with given id" do
      future_pick = insert(:future_pick)
      assert DraftPicks.get_future_pick!(future_pick.id).id == future_pick.id
    end

    test "get_future_pick_by/1 returns the future_pick with given clause" do
      future_pick = insert(:future_pick, round: 1)
      _other_future_pick = insert(:future_pick, round: 2)
      assert DraftPicks.get_future_pick_by(%{round: 1}).id == future_pick.id
    end

    test "get_future_pick_by/1 returns nil if doesn't exist" do
      _future_pick = insert(:future_pick, round: 1)
      assert DraftPicks.get_future_pick_by(%{round: 2}) == nil
    end

    test "list_future_picks_by_league/1 returns future picks for a league" do
      league = insert(:fantasy_league)
      other_league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "A", fantasy_league: league)
      team_b = insert(:fantasy_team, team_name: "B", fantasy_league: league)
      other_team = insert(:fantasy_team, fantasy_league: other_league)

      future_pick_b = insert(:future_pick, round: 1, current_team: team_b)
      future_pick2 = insert(:future_pick, round: 2, current_team: team)
      future_pick1 = insert(:future_pick, round: 1, current_team: team)
      _other_future_pick = insert(:future_pick, current_team: other_team)

      results = DraftPicks.list_future_picks_by_league(league.id)

      assert Enum.map(results, & &1.id) == [future_pick1.id, future_pick2.id, future_pick_b.id]
    end

    test "update_future_pick/2 with valid data updates the future_pick" do
      future_pick = insert(:future_pick)
      team = insert(:fantasy_team)
      attrs = %{current_team_id: team.id}

      assert {:ok, %FuturePick{} = result} = DraftPicks.update_future_pick(future_pick, attrs)

      assert result.current_team_id == team.id
    end

    test "update_future_pick/2 with invalid data returns error changeset" do
      future_pick = insert(:future_pick, round: 42)

      assert {:error, %Ecto.Changeset{}} =
               DraftPicks.update_future_pick(future_pick, @invalid_attrs)

      assert DraftPicks.get_future_pick!(future_pick.id).round == 42
    end
  end

  describe "draft_player/2" do
    test "updates draft pick and inserts new roster position" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      pick = insert(:draft_pick, fantasy_league: league, fantasy_team: team, draft_position: 1.01)
      player = insert(:fantasy_player)
      params = %{"fantasy_player_id" => player.id}

      {:ok, %{draft_pick: draft_pick, roster_position: position}} =
        DraftPicks.draft_player(pick, params)

      assert draft_pick.fantasy_player_id == player.id
      refute draft_pick.drafted_at == nil
      assert position.fantasy_team_id == team.id
      assert position.fantasy_player_id == player.id
      assert position.acq_method == "draft_pick:1.01"
    end

    test "creates a message when a draft chat exists" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      pick = insert(:draft_pick, fantasy_league: league, fantasy_team: team, draft_position: 1.01)
      player = insert(:fantasy_player)
      chat = insert(:chat)

      insert(:fantasy_league_draft,
        fantasy_league: league,
        chat: chat
      )

      params = %{"fantasy_player_id" => player.id}

      {:ok, %{draft_pick: draft_pick, roster_position: _position}} =
        DraftPicks.draft_player(pick, params)

      message = Repo.one!(Ex338.Chats.Message)

      assert draft_pick.fantasy_player_id == player.id
      assert message.content == "Brown drafted #{player.player_name} with pick #1.01"
    end

    test "updates pending draft queues to unavailable or drafted" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      pick = insert(:draft_pick, fantasy_league: league, fantasy_team: team)
      player = insert(:fantasy_player)
      params = %{"fantasy_player_id" => player.id}

      team2 = insert(:fantasy_team, fantasy_league: league)

      drafted =
        insert(
          :draft_queue,
          fantasy_team: team,
          fantasy_player: player,
          status: :pending
        )

      unavailable =
        insert(
          :draft_queue,
          fantasy_team: team2,
          fantasy_player: player,
          status: :pending
        )

      {
        :ok,
        %{
          unavailable_draft_queues: {1, nil},
          drafted_draft_queues: {1, nil}
        }
      } = DraftPicks.draft_player(pick, params)

      drafted_queue = Repo.get!(DraftQueue, drafted.id)
      unavailable_queue = Repo.get!(DraftQueue, unavailable.id)

      assert drafted_queue.status == :drafted
      assert unavailable_queue.status == :unavailable
    end

    test "does not update draft pick and returns error with invalid params" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      pick = insert(:draft_pick, fantasy_league: league, fantasy_team: team)
      params = %{"fantasy_player_id" => ""}

      {:error, :draft_pick, draft_pick_changeset, %{}} = DraftPicks.draft_player(pick, params)

      refute draft_pick_changeset.valid?
    end
  end

  describe "get_draft_pick!/1" do
    test "returns the draft pick for a given id" do
      draft_pick = insert(:draft_pick)
      assert DraftPicks.get_draft_pick!(draft_pick.id).id == draft_pick.id
    end
  end

  describe "get_last_picks/1" do
    test "by default returns last 5 picks in descending order" do
      league = insert(:fantasy_league)
      insert(:submitted_pick, draft_position: 1.04, fantasy_league: league)
      insert(:submitted_pick, draft_position: 1.05, fantasy_league: league)
      insert(:submitted_pick, draft_position: 1.10, fantasy_league: league)
      insert(:submitted_pick, draft_position: 1.15, fantasy_league: league)
      insert(:submitted_pick, draft_position: 1.24, fantasy_league: league)
      insert(:draft_pick, draft_position: 1.30, fantasy_league: league)

      results = DraftPicks.get_last_picks(league.id)

      assert Enum.map(results, & &1.draft_position) == [
               1.24,
               1.15,
               1.1,
               1.05,
               1.04
             ]
    end

    test "returns last X picks in descending order" do
      num_picks = 3
      league = insert(:fantasy_league)
      insert(:submitted_pick, draft_position: 1.04, fantasy_league: league)
      insert(:submitted_pick, draft_position: 1.05, fantasy_league: league)
      insert(:submitted_pick, draft_position: 1.10, fantasy_league: league)
      insert(:submitted_pick, draft_position: 1.15, fantasy_league: league)
      insert(:submitted_pick, draft_position: 1.24, fantasy_league: league)
      insert(:draft_pick, draft_position: 1.30, fantasy_league: league)

      results = DraftPicks.get_last_picks(league.id, num_picks)

      assert Enum.map(results, & &1.draft_position) == [
               1.24,
               1.15,
               1.1
             ]
    end
  end

  describe "get_next_picks/1" do
    test "by default returns next 5 picks in descending order" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team)
      player = insert(:fantasy_player)

      insert(
        :draft_pick,
        draft_position: 1.04,
        fantasy_league: league,
        fantasy_team: team,
        fantasy_player: player
      )

      insert(:draft_pick, draft_position: 1.05, fantasy_league: league)
      insert(:draft_pick, draft_position: 1.10, fantasy_league: league)
      insert(:draft_pick, draft_position: 1.15, fantasy_league: league)
      insert(:draft_pick, draft_position: 1.24, fantasy_league: league)
      insert(:draft_pick, draft_position: 1.30, fantasy_league: league)

      results = DraftPicks.get_next_picks(league.id)

      assert Enum.map(results, & &1.draft_position) == [
               1.05,
               1.1,
               1.15,
               1.24,
               1.3
             ]
    end

    test "returns next X picks in descending order" do
      num_picks = 3
      league = insert(:fantasy_league)
      team = insert(:fantasy_team)
      player = insert(:fantasy_player)

      insert(
        :draft_pick,
        draft_position: 1.04,
        fantasy_league: league,
        fantasy_team: team,
        fantasy_player: player
      )

      insert(:draft_pick, draft_position: 1.05, fantasy_league: league)
      insert(:draft_pick, draft_position: 1.10, fantasy_league: league)
      insert(:draft_pick, draft_position: 1.15, fantasy_league: league)
      insert(:draft_pick, draft_position: 1.24, fantasy_league: league)
      insert(:draft_pick, draft_position: 1.30, fantasy_league: league)

      results = DraftPicks.get_next_picks(league.id, num_picks)

      assert Enum.map(results, & &1.draft_position) == [
               1.05,
               1.1,
               1.15
             ]
    end
  end

  describe "get_picks_available_with_skips/1" do
    test "returns available picks to make with skips" do
      league = insert(:fantasy_league, max_draft_hours: 1)
      team_a = insert(:fantasy_team, fantasy_league: league)
      team_b = insert(:fantasy_team, fantasy_league: league)
      team_c = insert(:fantasy_team, fantasy_league: league)
      team_d = insert(:fantasy_team, fantasy_league: league)

      player_a = insert(:fantasy_player)
      player_b = insert(:fantasy_player)
      player_c = insert(:fantasy_player)

      _completed_pick =
        insert(:draft_pick,
          draft_position: 1,
          fantasy_team: team_a,
          fantasy_player: player_a,
          fantasy_league: league,
          drafted_at: DateTime.from_naive!(~N[2018-09-21 01:10:02.857392], "Etc/UTC")
        )

      _over_limit_pick =
        insert(:draft_pick,
          draft_position: 2,
          fantasy_team: team_b,
          fantasy_player: player_b,
          fantasy_league: league,
          drafted_at: DateTime.from_naive!(~N[2018-09-21 03:10:02.857392], "Etc/UTC")
        )

      _over_limit_pick2 =
        insert(:draft_pick,
          draft_position: 3,
          fantasy_team: team_c,
          fantasy_player: player_c,
          fantasy_league: league,
          drafted_at: DateTime.from_naive!(~N[2018-09-21 05:10:02.857392], "Etc/UTC")
        )

      skipped_pick =
        insert(:draft_pick, draft_position: 4, fantasy_team: team_b, fantasy_league: league)

      skipped_pick2 =
        insert(:draft_pick, draft_position: 5, fantasy_team: team_c, fantasy_league: league)

      next_pick =
        insert(:draft_pick, draft_position: 6, fantasy_team: team_d, fantasy_league: league)

      _not_available =
        insert(:draft_pick, draft_position: 7, fantasy_team: team_a, fantasy_league: league)

      results = DraftPicks.get_picks_available_with_skips(league.id)

      assert Enum.map(results, & &1.id) == [skipped_pick.id, skipped_pick2.id, next_pick.id]
    end
  end

  describe "get_picks_for_league/1" do
    test "returns draft picks in descending order" do
      league = insert(:fantasy_league)
      player1 = insert(:fantasy_player)
      player2 = insert(:fantasy_player)
      player3 = insert(:fantasy_player)

      insert(:submitted_pick,
        draft_position: 1.05,
        fantasy_league: league,
        fantasy_player: player1,
        drafted_at: DateTime.from_naive!(~N[2018-09-21 01:02:02.857392], "Etc/UTC")
      )

      insert(:submitted_pick,
        draft_position: 1.04,
        fantasy_league: league,
        fantasy_player: player2,
        drafted_at: DateTime.from_naive!(~N[2018-09-21 01:00:02.857392], "Etc/UTC")
      )

      insert(:draft_pick,
        draft_position: 1.10,
        fantasy_league: league,
        fantasy_player: player3,
        drafted_at: DateTime.from_naive!(~N[2018-09-21 01:06:02.857392], "Etc/UTC")
      )

      other_league = insert(:fantasy_league)
      insert(:draft_pick, draft_position: 1.02, fantasy_league: other_league)

      %{draft_picks: picks, fantasy_teams: teams} = DraftPicks.get_picks_for_league(league.id)
      [first_pick | _] = picks

      assert Enum.map(picks, & &1.draft_position) == [1.04, 1.05, 1.1]
      assert first_pick.fantasy_league.id == league.id
      assert Enum.map(teams, & &1.avg_seconds_on_the_clock) == [0, 120, 240]
    end
  end
end
