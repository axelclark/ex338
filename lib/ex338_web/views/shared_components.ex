defmodule Ex338Web.SharedComponents do
  @moduledoc false

  def page_header(assigns \\ %{}, do: block) do
    render_template("page_header.html", assigns, block)
  end

  def section_header(assigns \\ %{}, do: block) do
    render_template("section_header.html", assigns, block)
  end

  def table(assigns \\ %{}, do: block) do
    render_template("table.html", assigns, block)
  end

  def table_th(assigns \\ %{}, do: block) do
    render_template("table_th.html", assigns, block)
  end

  def table_td(assigns \\ %{}, do: block) do
    render_template("table_td.html", assigns, block)
  end

  defp render_template(template, assigns, block) do
    assigns =
      assigns
      |> Map.new()
      |> Map.put(:inner_content, block)

    Ex338Web.SharedView.render(template, assigns)
  end
end
