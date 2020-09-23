defmodule Ex338Web.Commish.FantasyLeagueView do
  use Ex338Web, :view

  def trade_admin_buttons(trade) do
    approve =
      link("Approve",
        to: "#",
        id: "approve-trade-#{trade.id}",
        "phx-click": "update_trade",
        "phx-value-id": trade.id,
        "phx-value-status": "Approved",
        class:
          "inline-flex items-center px-2.5 py-1.5 border border-gray-300 text-xs leading-4 font-medium rounded text-indigo-700 bg-white hover:text-gray-500 focus:outline-none focus:border-blue-300 focus:shadow-outline-blue active:text-gray-800 active:bg-gray-50 transition ease-in-out duration-150"
      )

    reject =
      link("Disapprove",
        to: "#",
        id: "disapprove-trade-#{trade.id}",
        "phx-click": "update_trade",
        "phx-value-id": trade.id,
        "phx-value-status": "Disapproved",
        class:
          "inline-flex items-center ml-1 mt-1 px-2.5 py-1.5 border border-gray-300 text-xs leading-4 font-medium rounded text-red-700 bg-white hover:text-gray-500 focus:outline-none focus:border-blue-300 focus:shadow-outline-blue active:text-gray-800 active:bg-gray-50 transition ease-in-out duration-150"
      )

    [approve, reject]
  end

  def injured_reserve_admin_buttons(%{status: :submitted} = injured_reserve) do
    approve =
      link("Approve",
        to: "#",
        id: "approve-injured-reserve-#{injured_reserve.id}",
        "phx-click": "update_injured_reserve",
        "phx-value-id": injured_reserve.id,
        "phx-value-status": "approved",
        class:
          "inline-flex items-center px-2.5 py-1.5 border border-gray-300 text-xs leading-4 font-medium rounded text-indigo-700 bg-white hover:text-gray-500 focus:outline-none focus:border-blue-300 focus:shadow-outline-blue active:text-gray-800 active:bg-gray-50 transition ease-in-out duration-150"
      )

    reject =
      link("Reject",
        to: "#",
        id: "reject-injured-reserve-#{injured_reserve.id}",
        "phx-click": "update_injured_reserve",
        "phx-value-id": injured_reserve.id,
        "phx-value-status": "rejected",
        class:
          "inline-flex items-center ml-1 mt-1 px-2.5 py-1.5 border border-gray-300 text-xs leading-4 font-medium rounded text-red-700 bg-white hover:text-gray-500 focus:outline-none focus:border-blue-300 focus:shadow-outline-blue active:text-gray-800 active:bg-gray-50 transition ease-in-out duration-150"
      )

    [approve, reject]
  end

  def injured_reserve_admin_buttons(%{status: :approved} = injured_reserve) do
    approved =
      link("Return",
        id: "return-injured-reserve-#{injured_reserve.id}",
        to: "#",
        "phx-click": "update_injured_reserve",
        "phx-value-id": injured_reserve.id,
        "phx-value-status": "returned",
        class:
          "inline-flex items-center px-2.5 py-1.5 border border-gray-300 text-xs leading-4 font-medium rounded text-indigo-700 bg-white hover:text-gray-500 focus:outline-none focus:border-blue-300 focus:shadow-outline-blue active:text-gray-800 active:bg-gray-50 transition ease-in-out duration-150"
      )

    [approved]
  end
end
