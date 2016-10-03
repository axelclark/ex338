defmodule Ex338.WaiverAdminTest do
  use Ex338.ModelCase
  alias Ex338.{WaiverAdmin}

  describe "set_datetime_to_process/2" do
    test "adds the datetime to process 3 days from now if no existing" do
      params = %{"add_fantasy_player_id" => 1}
      team = insert(:fantasy_team)

      result = WaiverAdmin.set_datetime_to_process(params, team.id)

      assert Map.get(result, "process_at") > Ecto.DateTime.utc
    end

    test "adds existing datetime if there is an existing waiver for a player" do
      date = Ecto.DateTime.cast!(
        %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010})
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      player = insert(:fantasy_player)
      insert(:waiver, fantasy_team: team, add_fantasy_player: player,
                      status: "pending", process_at: date)
      params = %{"add_fantasy_player_id" => player.id}

      result = WaiverAdmin.set_datetime_to_process(params, team.id)

      assert Map.get(result, "process_at") == date
    end

    test "adds the datetime even if just dropping a player" do
      params = %{"drop_fantasy_player_id" => 1}
      team = insert(:fantasy_team)

      result = WaiverAdmin.set_datetime_to_process(params, team.id)

      assert Map.get(result, "process_at") > Ecto.DateTime.utc
    end
  end
end
