defmodule Ex338.PageController do
  use Ex338.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
