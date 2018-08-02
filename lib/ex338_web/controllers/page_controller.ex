defmodule Ex338Web.PageController do
  use Ex338Web, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def rules_2017(conn, _params) do
    render(conn, "2017_rules.html")
  end

  def rules_2018(conn, _params) do
    render(conn, "2018_rules.html")
  end

  def rules_2019(conn, _params) do
    render(conn, "2019_rules.html")
  end
end
