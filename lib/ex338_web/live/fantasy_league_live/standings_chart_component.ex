defmodule Ex338Web.FantasyLeagueLive.StandingsChartComponent do
  @moduledoc false
  use Ex338Web, :live_component

  @impl true
  def update(%{standings_chart_data: data}, socket) do
    spec =
      [title: "Standings History", width: :container, height: :container]
      |> VegaLite.new()
      |> VegaLite.data_from_values(data, only: ["date", "points", "team_name"])
      |> VegaLite.mark(:line)
      |> VegaLite.encode_field(:x, "date", type: :temporal)
      |> VegaLite.encode_field(:y, "points", type: :quantitative)
      |> VegaLite.encode_field(:color, "team_name", type: :nominal, scale: [scheme: "category20"])
      # Output the specifcation
      |> VegaLite.to_spec()

    socket = assign(socket, id: socket.id)
    {:ok, push_event(socket, "vega_lite:#{socket.id}:init", %{"spec" => spec})}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="overflow-hidden bg-white shadow sm:rounded-lg">
      <div class="px-4 py-5 sm:p-6">
        <div
          style="width:100%; height: 800px"
          id="graph"
          phx-hook="VegaLiteHook"
          phx-update="ignore"
          data-id={@id}
        />
      </div>
    </div>
    """
  end
end
