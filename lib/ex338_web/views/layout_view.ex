defmodule Ex338Web.LayoutView do
  use Ex338Web, :view

  def display(fantasy_leagues, navbar, draft_method \\ :redraft) do
    fantasy_leagues
    |> filter_by_navbar(navbar)
    |> filter_by_draft_method(draft_method)
    |> sort_by_div
    |> sort_by_year
  end

  def commish_tab_link(current_route, link, content) do
    opts = [
      href: link,
      class:
        "px-1 py-4 first:ml-0 ml-8 text-sm font-medium text-gray-500 whitespace-no-wrap border-b-2 border-transparent leading-5 hover:text-gray-700 hover:border-gray-300 focus:outline-none focus:text-gray-700 focus:border-gray-300"
    ]

    current = [
      class:
        "px-1 py-4 first:ml-0 ml-8 text-sm font-medium text-indigo-600 whitespace-no-wrap border-b-2 border-indigo-500 leading-5 focus:outline-none focus:text-indigo-800 focus:border-indigo-700"
    ]

    opts =
      if current_route == link do
        Keyword.merge(opts, current)
      else
        opts
      end

    content_tag(:a, opts, content)
  end

  def sidebar_link(conn, link, content) do
    opts = [
      href: link,
      class:
        "mt-1 first:mt-0 group flex items-center px-2 py-1 text-sm leading-5 font-medium text-gray-300 rounded-md hover:text-white hover:bg-gray-700 focus:outline-none focus:text-white focus:bg-gray-700 transition ease-in-out duration-150"
    ]

    current = [
      class:
        "mt-1 first:mt-0 group flex items-center px-2 py-1 text-sm leading-5 font-medium text-white rounded-md bg-gray-900 focus:outline-none focus:bg-gray-700 transition ease-in-out duration-150"
    ]

    opts =
      if conn.request_path == trim_query_params(link) do
        Keyword.merge(opts, current)
      else
        opts
      end

    content_tag(:a, opts, content)
  end

  def sidebar_mobile_link(conn, link, content) do
    opts = [
      href: link,
      class:
        "mt-1 first:mt-0 group flex items-center px-2 py-2 text-base leading-6 font-medium rounded-md text-gray-300 hover:text-white hover:bg-gray-700 focus:outline-none focus:text-white focus:bg-gray-700 transition ease-in-out duration-150"
    ]

    current = [
      class:
        "mt-1 first:mt-0 group flex items-center px-2 py-2 text-base leading-6 font-medium rounded-md text-white bg-gray-900 focus:outline-none focus:bg-gray-700 transition ease-in-out duration-150"
    ]

    opts =
      if conn.request_path == trim_query_params(link) do
        Keyword.merge(opts, current)
      else
        opts
      end

    content_tag(:a, opts, content)
  end

  def sidebar_mobile_svg(content) do
    opts = [
      "stroke-linecap": "round",
      "stroke-linejoin": "round",
      "stroke-width": "2",
      fill: "none",
      viewBox: "0 0 24 24",
      stroke: "currentColor",
      class:
        "mr-4 h-6 w-6 text-gray-300 group-hover:text-gray-300 group-focus:text-gray-300 transition ease-in-out duration-150"
    ]

    content_tag(:svg, opts, content)
  end

  def sidebar_svg(content) do
    opts = [
      "stroke-linecap": "round",
      "stroke-linejoin": "round",
      "stroke-width": "2",
      fill: "none",
      viewBox: "0 0 24 24",
      stroke: "currentColor",
      class:
        "mr-3 h-6 w-6 text-gray-400 group-hover:text-gray-300 group-focus:text-gray-300 transition ease-in-out duration-150"
    ]

    content_tag(:svg, opts, content)
  end

  def show_nav_components?(conn) do
    conn.request_path != Routes.pow_session_path(conn, :new)
  end

  ## Helpers

  defp trim_query_params(link) do
    [link] = String.split(link, "?") |> Enum.take(1)
    link
  end

  ## display

  defp filter_by_draft_method(fantasy_leagues, draft_method) do
    Enum.filter(fantasy_leagues, &(&1.draft_method == draft_method))
  end

  defp filter_by_navbar(fantasy_leagues, navbar) do
    Enum.filter(fantasy_leagues, &(&1.navbar_display == navbar))
  end

  defp sort_by_div(fantasy_leagues) do
    Enum.sort_by(fantasy_leagues, & &1.division)
  end

  defp sort_by_year(fantasy_leagues) do
    Enum.sort_by(fantasy_leagues, & &1.year, &>=/2)
  end
end
