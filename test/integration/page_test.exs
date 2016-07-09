defmodule Ex338.PageTest do
  use Ex338.AcceptanceCase, async: true

  test "home page", %{session: session} do
    page = 
      session
      |> visit("/")
      |> find(".jumbotron")

    assert has_text?(page, "Welcome to Phoenix!")
  end
end
