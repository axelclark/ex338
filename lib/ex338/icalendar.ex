defmodule Ex338.ICalendar do
  @moduledoc false

  defmodule Event do
    @moduledoc false
    defstruct summary: nil,
              dtstart: nil,
              dtend: nil,
              dtstamp: nil,
              description: nil,
              uid: nil
  end

  def to_ics(events) when is_list(events) do
    events = Enum.map(events, &to_ics/1)

    """
    BEGIN:VCALENDAR
    CALSCALE:GREGORIAN
    VERSION:2.0
    PRODID:-//Ex338 ICalendar//EN
    #{events}END:VCALENDAR
    """
  end

  def to_ics(event) do
    contents = to_kvs(event)

    """
    BEGIN:VEVENT
    #{contents}END:VEVENT
    """
  end

  defp to_kvs(event) do
    event
    |> Map.from_struct()
    |> Enum.map(&to_kv/1)
    |> List.flatten()
    |> Enum.sort()
    |> Enum.join()
  end

  defp to_kv({key, value}) do
    name =
      key
      |> to_string()
      |> String.upcase()

    build(name, value)
  end

  def build(_key, nil) do
    ""
  end

  def build(key, %Date{} = date) do
    "#{key}:#{Date.to_iso8601(date, :basic)}\n"
  end

  def build(key, %DateTime{} = datetime) do
    datetime =
      datetime
      |> DateTime.truncate(:second)
      |> DateTime.to_iso8601(:basic)

    "#{key}:#{datetime}\n"
  end

  def build(key, value) do
    "#{key}:#{value}\n"
  end
end
