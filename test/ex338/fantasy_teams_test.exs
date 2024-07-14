defmodule Ex338.FantasyTeamsTest do
  use Ex338.DataCase, async: true

  alias Ex338.FantasyTeams
  alias Ex338.FantasyTeams.Owner

  describe "count_pending_draft_queues/1" do
    test "returns number of pending draft queues for a team" do
      team = insert(:fantasy_team)
      insert(:draft_queue, fantasy_team: team)

      result = FantasyTeams.count_pending_draft_queues(team.id)

      assert result == 1
    end
  end

  describe "find_all_for_league/1" do
    test "returns only fantasy teams in a league with open positions added" do
      league = insert(:fantasy_league)
      other_league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)

      _other_team =
        insert(
          :fantasy_team,
          team_name: "Another Team",
          fantasy_league: other_league
        )

      sport = insert(:sports_league, abbrev: "CFB")
      insert(:league_sport, fantasy_league: league, sports_league: sport)

      insert(:roster_position, position: "Unassigned", fantasy_team: team)
      insert(:roster_position, status: "injured_reserve", fantasy_team: team)
      open_position = "CFB"

      teams = FantasyTeams.find_all_for_league(league)
      %{roster_positions: positions} = List.first(teams)
      team = List.first(teams)

      assert Enum.map(teams, & &1.team_name) == ~w(Brown)
      assert Enum.any?(positions, &(&1.position == "Unassigned"))
      assert Enum.any?(positions, &(&1.position == open_position))
      assert Enum.count(team.ir_positions) == 1
    end
  end

  describe "find_all_for_standings/1" do
    test "returns only fantasy teams in a league sorted by points" do
      league = insert(:fantasy_league)
      other_league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)

      _other_team =
        insert(
          :fantasy_team,
          team_name: "Another Team",
          fantasy_league: other_league
        )

      insert(:roster_position, position: "Unassigned", fantasy_team: team)
      insert(:roster_position, status: "injured_reserve", fantasy_team: team)

      teams = FantasyTeams.find_all_for_standings(league)

      assert Enum.map(teams, & &1.team_name) == ~w(Brown)
      assert Enum.map(teams, & &1.points) == [0]
    end
  end

  describe "find_all_for_standings_by_date/2" do
    test "returns only fantasy teams in a league with points as of a date" do
      {:ok, jun_date, _} = DateTime.from_iso8601("2018-06-01T00:00:00Z")

      league = insert(:fantasy_league, year: 2018)
      other_league = insert(:fantasy_league, year: 2018)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)

      _other_team =
        insert(
          :fantasy_team,
          team_name: "Another Team",
          fantasy_league: other_league
        )

      insert(:roster_position, position: "Unassigned", fantasy_team: team)
      insert(:roster_position, status: "injured_reserve", fantasy_team: team)

      teams = FantasyTeams.find_all_for_standings_by_date(league, jun_date)

      assert Enum.map(teams, & &1.team_name) == ~w(Brown)
      assert Enum.map(teams, & &1.points) == [0]
    end
  end

  describe "find_all_for_league_sport/2" do
    test "returns teams in a league with active positions for a sport" do
      fantasy_league = insert(:fantasy_league)
      other_fantasy_league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: fantasy_league)
      other_team = insert(:fantasy_team, fantasy_league: other_fantasy_league)
      league = insert(:sports_league)
      other_league = insert(:sports_league)
      player_a = insert(:fantasy_player, sports_league: league)
      player_b = insert(:fantasy_player, sports_league: other_league)
      player_c = insert(:fantasy_player, sports_league: league)

      pos =
        insert(:roster_position, fantasy_player: player_a, status: "active", fantasy_team: team)

      insert(:roster_position, fantasy_player: player_b, status: "active", fantasy_team: team)

      insert(
        :roster_position,
        fantasy_player: player_c,
        status: "active",
        fantasy_team: other_team
      )

      [%{roster_positions: [result]}] =
        FantasyTeams.find_all_for_league_sport(fantasy_league.id, league.id)

      assert result.id == pos.id
    end
  end

  describe "find/1" do
    test "returns team with assocs and calculated fields" do
      league = insert(:fantasy_league)

      team =
        insert(
          :fantasy_team,
          team_name: "Brown",
          fantasy_league: league,
          winnings_received: 75.00,
          dues_paid: 100.00
        )

      user = insert_user(%{name: "Axel"})
      insert(:owner, user: user, fantasy_team: team)

      sport = insert(:sports_league, abbrev: "CFB")
      insert(:league_sport, fantasy_league: league, sports_league: sport)

      player = insert(:fantasy_player, player_name: "Houston", sports_league: sport)
      dropped_player = insert(:fantasy_player)
      ir_player = insert(:fantasy_player)

      insert(:roster_position, position: "Unassigned", fantasy_team: team, fantasy_player: player)

      insert(
        :roster_position,
        fantasy_team: team,
        fantasy_player: dropped_player,
        status: "dropped"
      )

      insert(
        :roster_position,
        fantasy_team: team,
        fantasy_player: ir_player,
        status: "injured_reserve"
      )

      team = FantasyTeams.find(team.id)

      assert %{team_name: "Brown"} = team
      assert Enum.count(team.roster_positions) == 8
    end
  end

  describe "find_for_edit/1" do
    test "gets a team for the edit form" do
      team = insert(:fantasy_team, team_name: "Brown")
      insert(:roster_position, fantasy_team: team)

      result = FantasyTeams.find_for_edit(team.id)

      assert result.team_name == team.team_name
      assert Enum.count(result.roster_positions) == 1
    end
  end

  describe "find_owned_players/1" do
    test "returns all owned players for a team" do
      player_a = insert(:fantasy_player)
      player_b = insert(:fantasy_player)
      _player_c = insert(:fantasy_player)
      player_d = insert(:fantasy_player)
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      insert(:roster_position, fantasy_team: team, fantasy_player: player_a, status: "active")
      insert(:roster_position, fantasy_team: team, fantasy_player: player_b, status: "released")

      insert(
        :roster_position,
        fantasy_team: team,
        fantasy_player: player_d,
        status: "injured_reserve"
      )

      [result] = FantasyTeams.find_owned_players(team.id)

      assert result.id == player_a.id
    end
  end

  describe "get_email_recipients_for_league/2" do
    test "return email addresses for a league" do
      league_a = insert(:fantasy_league)
      league_b = insert(:fantasy_league)
      team_a = insert(:fantasy_team, team_name: "A", fantasy_league: league_a)
      team_b = insert(:fantasy_team, team_name: "B", fantasy_league: league_b)
      user_a = insert_user()
      user_b = insert_user()
      insert(:owner, fantasy_team: team_a, user: user_a)
      insert(:owner, fantasy_team: team_b, user: user_b)

      result = FantasyTeams.get_email_recipients_for_league(league_a.id)

      assert result == [{user_a.name, user_a.email}]
    end
  end

  describe "get_email_recipients_for_team/2" do
    test "return email addresses for a team" do
      league = insert(:fantasy_league)
      team_a = insert(:fantasy_team, team_name: "A", fantasy_league: league)
      team_b = insert(:fantasy_team, team_name: "B", fantasy_league: league)
      user_a = insert_user()
      user_b = insert_user()
      insert(:owner, fantasy_team: team_a, user: user_a)
      insert(:owner, fantasy_team: team_b, user: user_b)

      result = FantasyTeams.get_email_recipients_for_team(team_a.id)

      assert result == [{user_a.name, user_a.email}]
    end
  end

  describe "get_leagues_email_recipients/1" do
    test "return email addresses for multiple leagues" do
      league_a = insert(:fantasy_league)
      league_b = insert(:fantasy_league)
      team_a = insert(:fantasy_team, team_name: "A", fantasy_league: league_a)
      team_b = insert(:fantasy_team, team_name: "B", fantasy_league: league_b)
      user_a = insert_user()
      user_b = insert_user()
      _user_c = insert_user()
      insert(:owner, fantasy_team: team_a, user: user_a)
      insert(:owner, fantasy_team: team_b, user: user_b)

      result =
        FantasyTeams.get_leagues_email_addresses([
          league_a.id,
          league_b.id
        ])

      assert result == [
               {user_b.name, user_b.email},
               {user_a.name, user_a.email}
             ]
    end
  end

  describe "get_team_with_active_positions/1" do
    test "returns team with all active positions preloaded" do
      team = insert(:fantasy_team)
      active = insert(:roster_position, status: "active", fantasy_team: team)
      insert(:roster_position, status: "traded", fantasy_team: team)

      %{roster_positions: [result]} = FantasyTeams.get_team_with_active_positions(team.id)

      assert result.id == active.id
    end
  end

  describe "list_teams_for_league/1" do
    test "returns all teams for a league" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league, team_name: "A")
      team_b = insert(:fantasy_team, fantasy_league: league, team_name: "B")
      other_league = insert(:fantasy_league)
      _other_team = insert(:fantasy_team, fantasy_league: other_league)

      results = FantasyTeams.list_teams_for_league(league.id)

      assert Enum.map(results, & &1.id) == [team.id, team_b.id]
    end
  end

  describe "list_teams_for_user/1" do
    test "returns a list of teams for a user sorted by most recent and division" do
      user = insert(:user)
      league_a = insert(:fantasy_league, year: 2020, division: "B")
      league_b = insert(:fantasy_league, year: 2021, division: "A")
      league_c = insert(:fantasy_league, year: 2020, division: "A")
      team_a = insert(:fantasy_team, fantasy_league: league_a)
      team_b = insert(:fantasy_team, fantasy_league: league_b)
      team_c = insert(:fantasy_team, fantasy_league: league_c)
      _team_d = insert(:fantasy_team)

      insert(:owner, fantasy_team: team_a, user: user)
      insert(:owner, fantasy_team: team_b, user: user)
      insert(:owner, fantasy_team: team_c, user: user)

      results = FantasyTeams.list_teams_for_user(user.id)

      assert Enum.map(results, & &1.id) == [team_b.id, team_c.id, team_a.id]
    end

    test "returns an empty list for a user without a team" do
      user = insert(:user)

      assert FantasyTeams.list_teams_for_user(user.id) == []
    end
  end

  describe "load_slot_results/1" do
    test "returns slots for teams in league with points summed" do
      league = insert(:fantasy_league)
      league2 = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      team2 = insert(:fantasy_team, fantasy_league: league2)

      sport = insert(:sports_league)
      championship = insert(:championship, sports_league: sport)
      championship2 = insert(:championship, sports_league: sport)
      player = insert(:fantasy_player, sports_league: sport)
      player2 = insert(:fantasy_player, sports_league: sport)
      player3 = insert(:fantasy_player, sports_league: sport)

      pos = insert(:roster_position, fantasy_team: team, fantasy_player: player)
      pos2 = insert(:roster_position, fantasy_team: team, fantasy_player: player2)
      pos3 = insert(:roster_position, fantasy_team: team2, fantasy_player: player3)

      _slot1 =
        insert(
          :championship_slot,
          roster_position: pos,
          championship: championship,
          slot: 1
        )

      _slot2 =
        insert(
          :championship_slot,
          roster_position: pos2,
          championship: championship,
          slot: 2
        )

      _slot3 =
        insert(
          :championship_slot,
          roster_position: pos,
          championship: championship2,
          slot: 1
        )

      _slot4 =
        insert(
          :championship_slot,
          roster_position: pos3,
          championship: championship2,
          slot: 1
        )

      _champ_result1 =
        insert(
          :championship_result,
          championship: championship,
          fantasy_player: player,
          points: 8,
          rank: 1
        )

      _champ_result2 =
        insert(
          :championship_result,
          championship: championship,
          fantasy_player: player2,
          points: 5,
          rank: 2
        )

      _champ_result3 =
        insert(
          :championship_result,
          championship: championship2,
          fantasy_player: player,
          points: 5,
          rank: 2
        )

      _champ_result4 =
        insert(
          :championship_result,
          championship: championship2,
          fantasy_player: player3,
          points: 8,
          rank: 1
        )

      [%{slot_results: [result1, result2]}] =
        league.id
        |> FantasyTeams.list_teams_for_league()
        |> FantasyTeams.load_slot_results()

      assert result1.fantasy_team_id == team.id
      assert result1.points == 13
      assert result1.slot == 1
      assert result1.sport_abbrev == sport.abbrev
      assert result1.rank == 1

      assert result2.fantasy_team_id == team.id
      assert result2.points == 5
      assert result2.slot == 2
      assert result2.sport_abbrev == sport.abbrev
      assert result1.rank == 1
    end

    test "returns slots for a team in a league with points summed" do
      league = insert(:fantasy_league)
      league2 = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      team2 = insert(:fantasy_team, fantasy_league: league2)

      sport = insert(:sports_league)
      championship = insert(:championship, sports_league: sport)
      championship2 = insert(:championship, sports_league: sport)
      player = insert(:fantasy_player, sports_league: sport)
      player2 = insert(:fantasy_player, sports_league: sport)
      player3 = insert(:fantasy_player, sports_league: sport)

      pos = insert(:roster_position, fantasy_team: team, fantasy_player: player)
      pos2 = insert(:roster_position, fantasy_team: team, fantasy_player: player2)
      pos3 = insert(:roster_position, fantasy_team: team2, fantasy_player: player3)

      _slot1 =
        insert(
          :championship_slot,
          roster_position: pos,
          championship: championship,
          slot: 1
        )

      _slot2 =
        insert(
          :championship_slot,
          roster_position: pos2,
          championship: championship,
          slot: 2
        )

      _slot3 =
        insert(
          :championship_slot,
          roster_position: pos,
          championship: championship2,
          slot: 1
        )

      _slot4 =
        insert(
          :championship_slot,
          roster_position: pos3,
          championship: championship2,
          slot: 1
        )

      _champ_result1 =
        insert(
          :championship_result,
          championship: championship,
          fantasy_player: player,
          points: 8,
          rank: 1
        )

      _champ_result2 =
        insert(
          :championship_result,
          championship: championship,
          fantasy_player: player2,
          points: 5,
          rank: 2
        )

      _champ_result3 =
        insert(
          :championship_result,
          championship: championship2,
          fantasy_player: player,
          points: 5,
          rank: 2
        )

      _champ_result4 =
        insert(
          :championship_result,
          championship: championship2,
          fantasy_player: player3,
          points: 8,
          rank: 1
        )

      %{slot_results: [result1, result2]} = FantasyTeams.load_slot_results(team)

      assert result1.fantasy_team_id == team.id
      assert result1.points == 13
      assert result1.slot == 1
      assert result1.sport_abbrev == sport.abbrev
      assert result1.rank == 1

      assert result2.fantasy_team_id == team.id
      assert result2.points == 5
      assert result2.slot == 2
      assert result2.sport_abbrev == sport.abbrev
      assert result2.rank == 2
    end
  end

  describe "owned_players_for_league/1" do
    test "returns all owned players for a league" do
      player_a = insert(:fantasy_player)
      player_b = insert(:fantasy_player)
      player_c = insert(:fantasy_player)
      _player_d = insert(:fantasy_player)
      league = insert(:fantasy_league)
      other_league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      team_b = insert(:fantasy_team, fantasy_league: league)
      other_team = insert(:fantasy_team, fantasy_league: other_league)
      insert(:roster_position, fantasy_team: team, fantasy_player: player_a, status: "active")
      insert(:roster_position, fantasy_team: team_b, fantasy_player: player_b, status: "active")

      insert(
        :roster_position,
        fantasy_team: other_team,
        fantasy_player: player_c,
        status: "active"
      )

      results = FantasyTeams.owned_players_for_league(league.id)

      assert Enum.map(results, & &1.id) == [player_a.id, player_b.id]
    end
  end

  describe "standings_history/1" do
    test "returns the total points for each team by month" do
      {:ok, feb_date, _} = DateTime.from_iso8601("2018-02-23T23:50:07Z")
      {:ok, jun_date, _} = DateTime.from_iso8601("2018-06-23T00:00:00Z")

      sport = insert(:sports_league)
      player_a = insert(:fantasy_player, sports_league: sport)
      player_b = insert(:fantasy_player, sports_league: sport)

      league = insert(:fantasy_league, year: 2018)
      insert(:league_sport, fantasy_league: league, sports_league: sport)

      team_a = insert(:fantasy_team, fantasy_league: league)
      insert(:roster_position, fantasy_team: team_a, fantasy_player: player_a)

      team_b = insert(:fantasy_team, fantasy_league: league)
      insert(:roster_position, fantasy_team: team_b, fantasy_player: player_b)

      feb_champ =
        insert(:championship, category: "overall", year: 2018, championship_at: feb_date)

      jun_champ =
        insert(:championship, category: "overall", year: 2018, championship_at: jun_date)

      _feb_champ_result =
        insert(
          :championship_result,
          championship: feb_champ,
          fantasy_player: player_a,
          points: 8
        )

      _jun_champ_result =
        insert(
          :championship_result,
          championship: jun_champ,
          fantasy_player: player_b,
          points: 8
        )

      _jun_champ_result_2 =
        insert(
          :championship_result,
          championship: jun_champ,
          fantasy_player: player_a,
          points: 5
        )

      [result_a, result_b] = FantasyTeams.standings_history(league)

      assert result_a.points == [0, 0, 8, 8, 8, 8, 13, 13, 13, 13, 13, 13]
      assert result_a.team_name == team_a.team_name
      assert result_b.points == [0, 0, 0, 0, 0, 0, 8, 8, 8, 8, 8, 8]
      assert result_b.team_name == team_b.team_name
    end
  end

  describe "list_standings_history/1" do
    test "returns the total points for each team by month" do
      feb_date = ~U[2023-02-12 00:01:00.00Z]
      jun_date = ~U[2023-06-12 00:01:00.00Z]

      sport = insert(:sports_league)
      player_a = insert(:fantasy_player, sports_league: sport)
      player_b = insert(:fantasy_player, sports_league: sport)

      league =
        insert(:fantasy_league,
          championships_start_at: ~U[2022-10-12 00:01:00.00Z],
          championships_end_at: ~U[2023-08-12 00:01:00.00Z]
        )

      insert(:league_sport, fantasy_league: league, sports_league: sport)

      team_a = insert(:fantasy_team, fantasy_league: league)
      insert(:roster_position, fantasy_team: team_a, fantasy_player: player_a)

      team_b = insert(:fantasy_team, fantasy_league: league)
      insert(:roster_position, fantasy_team: team_b, fantasy_player: player_b)

      feb_champ =
        insert(:championship, category: "overall", championship_at: feb_date)

      jun_champ =
        insert(:championship, category: "overall", championship_at: jun_date)

      _feb_champ_result =
        insert(
          :championship_result,
          championship: feb_champ,
          fantasy_player: player_a,
          points: 8
        )

      _jun_champ_result =
        insert(
          :championship_result,
          championship: jun_champ,
          fantasy_player: player_b,
          points: 8
        )

      _jun_champ_result_2 =
        insert(
          :championship_result,
          championship: jun_champ,
          fantasy_player: player_a,
          points: 5
        )

      results = FantasyTeams.list_standings_history(league)

      assert results == [
               %{team_name: team_a.team_name, date: ~U[2022-10-01 00:00:00.000Z], points: 0},
               %{team_name: team_b.team_name, date: ~U[2022-10-01 00:00:00.000Z], points: 0},
               %{team_name: team_a.team_name, date: ~U[2022-11-01 00:00:00.000Z], points: 0},
               %{team_name: team_b.team_name, date: ~U[2022-11-01 00:00:00.000Z], points: 0},
               %{team_name: team_a.team_name, date: ~U[2022-12-01 00:00:00.000Z], points: 0},
               %{team_name: team_b.team_name, date: ~U[2022-12-01 00:00:00.000Z], points: 0},
               %{team_name: team_a.team_name, date: ~U[2023-01-01 00:00:00.000Z], points: 0},
               %{team_name: team_b.team_name, date: ~U[2023-01-01 00:00:00.000Z], points: 0},
               %{team_name: team_a.team_name, date: ~U[2023-02-01 00:00:00.000Z], points: 0},
               %{team_name: team_b.team_name, date: ~U[2023-02-01 00:00:00.000Z], points: 0},
               %{team_name: team_a.team_name, date: ~U[2023-03-01 00:00:00.000Z], points: 8},
               %{team_name: team_b.team_name, date: ~U[2023-03-01 00:00:00.000Z], points: 0},
               %{team_name: team_a.team_name, date: ~U[2023-04-01 00:00:00.000Z], points: 8},
               %{team_name: team_b.team_name, date: ~U[2023-04-01 00:00:00.000Z], points: 0},
               %{team_name: team_a.team_name, date: ~U[2023-05-01 00:00:00.000Z], points: 8},
               %{team_name: team_b.team_name, date: ~U[2023-05-01 00:00:00.000Z], points: 0},
               %{team_name: team_a.team_name, date: ~U[2023-06-01 00:00:00.000Z], points: 8},
               %{team_name: team_b.team_name, date: ~U[2023-06-01 00:00:00.000Z], points: 0},
               %{team_name: team_a.team_name, date: ~U[2023-07-01 00:00:00.000Z], points: 13},
               %{team_name: team_b.team_name, date: ~U[2023-07-01 00:00:00.000Z], points: 8},
               %{team_name: team_a.team_name, date: ~U[2023-08-01 00:00:00.000Z], points: 13},
               %{team_name: team_b.team_name, date: ~U[2023-08-01 00:00:00.000Z], points: 8},
               %{team_name: team_a.team_name, date: ~U[2023-09-01 00:00:00.000Z], points: 13},
               %{team_name: team_b.team_name, date: ~U[2023-09-01 00:00:00.000Z], points: 8}
             ]
    end
  end

  describe "update_owner/2" do
    test "updates owner with valid attributes" do
      owner = insert(:owner, rules: "unaccepted")
      attrs = %{rules: "accepted"}

      assert {:ok, %Owner{} = owner} = FantasyTeams.update_owner(owner, attrs)
      assert owner.rules == :accepted
    end
  end

  describe "update_team/2" do
    test "updates a fantasy team and its roster positions" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      position = insert(:roster_position, fantasy_team: team)
      team = FantasyTeams.find_for_edit(team.id)

      attrs = %{
        "team_name" => "Cubs",
        "roster_positions" => %{"0" => %{"id" => position.id, "position" => "Flex1"}}
      }

      {:ok, team} = FantasyTeams.update_team(team, attrs)

      assert team.team_name == "Cubs"
      assert Enum.map(team.roster_positions, & &1.position) == ~w(Flex1)
    end
  end

  describe "without_player_from_sport/2" do
    test "returns teams from a league who don't own a player from a sport" do
      league1 = insert(:fantasy_league)
      league2 = insert(:fantasy_league)

      team_with_plyr = insert(:fantasy_team, fantasy_league: league1)
      team_with_two = insert(:fantasy_team, fantasy_league: league1)
      team_with_dropped = insert(:fantasy_team, fantasy_league: league1)
      team_with_other_sport = insert(:fantasy_team, fantasy_league: league1)
      _team_without_plyr = insert(:fantasy_team, fantasy_league: league1)
      team_from_other_league = insert(:fantasy_team, fantasy_league: league2)

      sport = insert(:sports_league)
      player1 = insert(:fantasy_player, sports_league: sport)
      player2 = insert(:fantasy_player, sports_league: sport)
      player3 = insert(:fantasy_player, sports_league: sport)
      player4 = insert(:fantasy_player, sports_league: sport)

      sport2 = insert(:sports_league)
      player5 = insert(:fantasy_player, sports_league: sport2)

      insert(:roster_position,
        fantasy_team: team_with_plyr,
        fantasy_player: player1,
        status: "active"
      )

      insert(:roster_position,
        fantasy_team: team_with_two,
        fantasy_player: player2,
        status: "active"
      )

      insert(:roster_position,
        fantasy_team: team_with_two,
        fantasy_player: player4,
        status: "active"
      )

      insert(:roster_position,
        fantasy_team: team_with_dropped,
        fantasy_player: player3,
        status: "dropped"
      )

      insert(:roster_position,
        fantasy_team: team_with_other_sport,
        fantasy_player: player5,
        status: "active"
      )

      insert(:roster_position,
        fantasy_team: team_from_other_league,
        fantasy_player: player3,
        status: "active"
      )

      result = FantasyTeams.without_player_from_sport(league1.id, sport.id)

      assert Enum.count(result) == 3
    end
  end
end
