defmodule Ex338Web.InjuredReserveView do
  use Ex338Web, :view

  def display_status_or_admin_buttons(conn, current_user, injured_reserve, fantasy_league) do
    with true <- current_user.admin,
         true <- for_admin_action?(injured_reserve) do
      display_admin_button(conn, injured_reserve, fantasy_league)
    else
      _ -> display_status(injured_reserve)
    end
  end

  # Helpers

  defp for_admin_action?(injured_reserve) do
    %{status: status} = injured_reserve

    status == :submitted ||
      status == :approved
  end

  defp display_admin_button(conn, %{status: :submitted} = injured_reserve, fantasy_league) do
    approve =
      link("Approve",
        to:
          Routes.fantasy_league_injured_reserve_path(
            conn,
            :update,
            fantasy_league.id,
            injured_reserve.id,
            %{"injured_reserve" => %{"status" => "approved"}}
          ),
        data: [confirm: "Please confirm to approve IR"],
        method: :patch,
        class:
          "inline-flex items-center px-2.5 py-1.5 border border-gray-300 text-xs leading-4 font-medium rounded text-indigo-700 bg-white hover:text-gray-500 focus:outline-none focus:border-blue-300 focus:shadow-outline-blue active:text-gray-800 active:bg-gray-50 transition ease-in-out duration-150"
      )

    reject =
      link("Reject",
        to:
          Routes.fantasy_league_injured_reserve_path(
            conn,
            :update,
            fantasy_league.id,
            injured_reserve.id,
            %{"injured_reserve" => %{"status" => "rejected"}}
          ),
        data: [confirm: "Please confirm to reject IR"],
        method: :patch,
        class:
          "inline-flex items-center px-2.5 py-1.5 border border-gray-300 text-xs leading-4 font-medium rounded text-indigo-700 bg-white hover:text-gray-500 focus:outline-none focus:border-blue-300 focus:shadow-outline-blue active:text-gray-800 active:bg-gray-50 transition ease-in-out duration-150"
      )

    [approve, reject]
  end

  defp display_admin_button(conn, %{status: :approved} = injured_reserve, fantasy_league) do
    approved =
      link("Return",
        to:
          Routes.fantasy_league_injured_reserve_path(
            conn,
            :update,
            fantasy_league.id,
            injured_reserve.id,
            %{"injured_reserve" => %{"status" => "returned"}}
          ),
        data: [confirm: "Please confirm to return IR"],
        method: :patch,
        class:
          "inline-flex items-center px-2.5 py-1.5 border border-gray-300 text-xs leading-4 font-medium rounded text-indigo-700 bg-white hover:text-gray-500 focus:outline-none focus:border-blue-300 focus:shadow-outline-blue active:text-gray-800 active:bg-gray-50 transition ease-in-out duration-150"
      )

    [approved]
  end

  defp display_admin_button(_conn, injured_reserve, _fantasy_league) do
    display_status(injured_reserve)
  end

  defp display_status(injured_reserve) do
    humanize(injured_reserve.status)
  end
end
