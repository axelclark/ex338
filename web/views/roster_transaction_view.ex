defmodule Ex338.RosterTransactionView do
  use Ex338.Web, :view
  use Timex

  def format_date(date) do
    {:ok, date} = Timex.format(date, "{Mshort} {D}, {YYYY}")
    date
  end
end
