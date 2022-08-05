defmodule Ex338Web.ChampionshipViewTest do
  use Ex338Web.ConnCase, async: true

  alias Ex338.{
    Accounts.User,
    Championships.Championship,
    Championships.ChampionshipSlot,
    InSeasonDraftPicks.InSeasonDraftPick
  }

  alias Ex338Web.{ChampionshipView}

  describe "get_team_name/1" do
    test "returns name from a fantasy team struct" do
      player = %{
        fantasy_player: %{
          roster_positions: [
            %{fantasy_team: %{team_name: "Brown"}}
          ]
        }
      }

      result = ChampionshipView.get_team_name(player)

      assert result == "Brown"
    end

    test "returns a dash if no positions" do
      player = %{fantasy_player: %{roster_positions: []}}

      result = ChampionshipView.get_team_name(player)

      assert result == "-"
    end
  end

  describe "filter_category/2" do
    test "filters list of championship by overall category" do
      championships = [
        %{name: "A", category: "overall"},
        %{name: "B", category: "overall"},
        %{name: "C", category: "event"},
        %{name: "D", category: "event"}
      ]

      results = ChampionshipView.filter_category(championships, "overall")

      assert Enum.map(results, & &1.name) == ~w(A B)
    end

    test "filters list of championship by event category" do
      championships = [
        %{name: "A", category: "overall"},
        %{name: "B", category: "overall"},
        %{name: "C", category: "event"},
        %{name: "D", category: "event"}
      ]

      results = ChampionshipView.filter_category(championships, "event")

      assert Enum.map(results, & &1.name) == ~w(C D)
    end
  end

  describe "display_drafted_at_or_pick_due_at/1" do
    test "returns dashes if haven't drafted and not available to pick" do
      pick = %InSeasonDraftPick{available_to_pick?: false, drafted_player_id: nil}

      result = ChampionshipView.display_drafted_at_or_pick_due_at(pick)

      assert result == "---"
    end

    test "return pick_due_at in PST if available to pick" do
      date = DateTime.from_naive!(~N[2017-09-16 22:30:00.000], "Etc/UTC")
      pick = %InSeasonDraftPick{available_to_pick?: true, pick_due_at: date}

      result = ChampionshipView.display_drafted_at_or_pick_due_at(pick)

      assert result == " 3:30 PM"
    end

    test "returns dashes if already picked but no drafted_at data" do
      pick = %InSeasonDraftPick{available_to_pick?: true, drafted_player_id: 1, drafted_at: nil}

      result = ChampionshipView.display_drafted_at_or_pick_due_at(pick)

      assert result == "---"
    end

    test "return drafted_at in PST if already picked" do
      date = DateTime.from_naive!(~N[2017-09-16 22:30:00.000], "Etc/UTC")
      pick = %InSeasonDraftPick{available_to_pick?: true, drafted_player_id: 1, drafted_at: date}

      result = ChampionshipView.display_drafted_at_or_pick_due_at(pick)

      assert result == " 3:30 PM"
    end
  end

  describe "show_create_slots/2" do
    test "return true if admin, event, and no slots" do
      user = %User{admin: true}
      championship = %Championship{category: "event", championship_slots: []}

      result = ChampionshipView.show_create_slots(user, championship)

      assert result == true
    end

    test "return false if admin, event, and slots" do
      user = %User{admin: true}
      championship = %Championship{category: "event", championship_slots: [%ChampionshipSlot{}]}

      result = ChampionshipView.show_create_slots(user, championship)

      assert result == false
    end

    test "return false if not admin" do
      user = %User{admin: false}
      championship = %Championship{category: "event", championship_slots: []}

      result = ChampionshipView.show_create_slots(user, championship)

      assert result == false
    end

    test "return false if no user" do
      user = nil
      championship = %Championship{category: "event", championship_slots: []}

      result = ChampionshipView.show_create_slots(user, championship)

      assert result == false
    end

    test "return false if overall" do
      user = %User{admin: true}
      championship = %Championship{category: "overall", championship_slots: []}

      result = ChampionshipView.show_create_slots(user, championship)

      assert result == false
    end
  end

  describe "show_create_picks/2" do
    test "return true if admin, in_season_draft, and no picks" do
      user = %User{admin: true}
      championship = %Championship{in_season_draft: true, in_season_draft_picks: []}

      result = ChampionshipView.show_create_picks(user, championship)

      assert result == true
    end

    test "return false if picks already created" do
      user = %User{admin: true}

      championship = %Championship{
        in_season_draft: true,
        in_season_draft_picks: [%InSeasonDraftPick{}]
      }

      result = ChampionshipView.show_create_picks(user, championship)

      assert result == false
    end

    test "return false if not admin" do
      user = %User{admin: false}
      championship = %Championship{in_season_draft: true, in_season_draft_picks: []}

      result = ChampionshipView.show_create_picks(user, championship)

      assert result == false
    end

    test "return false if in season draft is false" do
      user = %User{admin: true}
      championship = %Championship{in_season_draft: false, in_season_draft_picks: []}

      result = ChampionshipView.show_create_picks(user, championship)

      assert result == false
    end
  end
end
