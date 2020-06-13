defmodule Ex338Web.ExAdmin.Trade do
  @moduledoc false
  use ExAdmin.Register

  register_resource Ex338.Trades.Trade do
    index do
      selectable_column()

      column(:id)
      column(:inserted_at, label: "Date")
      column(:submitted_by_user)
      column(:submitted_by_team)
      column(:status)
      column(:additional_terms)
      actions()
    end

    form trade do
      inputs do
        input(trade, :submitted_by_user, collection: Ex338.User.all())
        input(trade, :submitted_by_team, collection: Ex338.FantasyTeams.FantasyTeam.all())
        input(trade, :status, collection: Ex338.Trades.Trade.status_options())
        input(trade, :additional_terms)
      end
    end

    show trade do
      attributes_table do
        row(:id)
        row(:inserted_at, label: "Date")
        row(:submitted_by_user)
        row(:submitted_by_team)
        row(:status)
        row(:additional_terms)
      end

      panel "Trade Line Items" do
        table_for trade.trade_line_items do
          column("Id", fn line_item ->
            Phoenix.HTML.safe_to_string(
              Phoenix.HTML.Link.link(
                "#{line_item.id}",
                to: "/admin/trade_line_items/#{line_item.id}/edit"
              )
            )
          end)

          column("Losing Team", fn line_item ->
            "#{line_item.losing_team.team_name}"
          end)

          column("Fantasy Player", fn line_item ->
            "#{line_item.fantasy_player.player_name}"
          end)

          column("Gaining Team", fn line_item ->
            "#{line_item.gaining_team.team_name}"
          end)
        end
      end
    end

    query do
      %{
        all: [
          preload: [
            :submitted_by_user,
            :submitted_by_team,
            trade_line_items: [
              :gaining_team,
              :losing_team,
              fantasy_player: :sports_league
            ]
          ]
        ]
      }
    end
  end
end
