defmodule Ex338.RosterTransactionViewTest do
  use Ex338.ConnCase, async: true
  alias Ex338.RosterTransactionView

  describe "format_date/1" do
    test "renders datetime as Month Day, Year" do
      my_date = Timex.to_datetime({{2016, 5, 15}, {4, 50, 34}}, :local)

      assert RosterTransactionView.format_date(my_date) == "May 15, 2016"
    end
  end
end
