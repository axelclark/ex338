defmodule Ex338Web.Components.LocalTime do
  @moduledoc false
  use Phoenix.Component

  @doc """
  Usage:
      now = DateTime.utc_now()
      in_one_month = DateTime.add(now, 40, :day)

      <.local_time for={now} />
      => Apr 3, 2023, 10:17 AM

      <.local_time for={now} preset="DATETIME_FULL" />
      => April 3, 2023 at 10:17 AM GMT+10

      <.local_time for={now} locale="fr" />
      => 3 avr. 2023, 10:17

      <.local_time for={now} format="yyyy mm dd" />
      => 2023 16 03

      <.local_time for={in_one_month} format="relative" />
      => in 1 month

  Preset options:
      DATE_SHORT => 10/14/1983
      DATE_MED => Oct 14, 1983
      DATE_MED_WITH_WEEKDAY => Fri, Oct 14, 1983
      DATE_FULL => October 14, 1983
      DATE_HUGE => Friday, October 14, 1983
      TIME_SIMPLE => 1:30 PM
      TIME_WITH_SECONDS => 1:30:23 PM
      TIME_WITH_SHORT_OFFSET => 1:30:23 PM EDT
      TIME_WITH_LONG_OFFSET => 1:30:23 PM Eastern Daylight Time
      TIME_24_SIMPLE => 13:30
      TIME_24_WITH_SECONDS => 13:30:23
      TIME_24_WITH_SHORT_OFFSET => 13:30:23 EDT
      TIME_24_WITH_LONG_OFFSET => 13:30:23 Eastern Daylight Time
      DATETIME_SHORT => 10/14/1983, 1:30 PM
      DATETIME_MED => Oct 14, 1983, 1:30 PM
      DATETIME_FULL => October 14, 1983 at 1:30 PM EDT
      DATETIME_HUGE => Friday, October 14, 1983 at 1:30 PM Eastern Daylight Time
      DATETIME_SHORT_WITH_SECONDS => 10/14/1983, 1:30:23 PM
      DATETIME_MED_WITH_SECONDS => Oct 14, 1983, 1:30:23 PM
      DATETIME_FULL_WITH_SECONDS => October 14, 1983 at 1:30:23 PM EDT
      DATETIME_HUGE_WITH_SECONDS => Friday, October 14, 1983 at 1:30:23 PM Eastern Daylight Time

  """

  attr :for, :any, doc: "A date-like type"

  attr :preset, :string,
    default: "DATETIME_MED",
    doc:
      "A shortcut to a specific format. Overrides 'format'. See https://moment.github.io/luxon/#/formatting?id=presets",
    values: [
      "DATE_SHORT",
      "DATE_MED",
      "DATE_MED_WITH_WEEKDAY",
      "DATE_FULL",
      "DATE_HUGE",
      "TIME_SIMPLE",
      "TIME_WITH_SECONDS",
      "TIME_WITH_SHORT_OFFSET",
      "TIME_WITH_LONG_OFFSET",
      "TIME_24_SIMPLE",
      "TIME_24_WITH_SECONDS",
      "TIME_24_WITH_SHORT_OFFSET",
      "TIME_24_WITH_LONG_OFFSET",
      "DATETIME_SHORT",
      "DATETIME_MED",
      "DATETIME_FULL",
      "DATETIME_HUGE",
      "DATETIME_SHORT_WITH_SECONDS",
      "DATETIME_MED_WITH_SECONDS",
      "DATETIME_FULL_WITH_SECONDS",
      "DATETIME_HUGE_WITH_SECONDS"
    ]

  attr :format, :string,
    default: nil,
    doc:
      "A date format string. See https://moment.github.io/luxon/#/formatting?id=table-of-tokens"

  attr :class, :string, default: nil, doc: "Classes to add to the time element"
  attr :locale, :string, default: "en", doc: "The locale to use"
  attr :rest, :global

  def local_time(assigns) do
    assigns =
      assign_new(assigns, :id, fn -> Ecto.UUID.generate() end)

    ~H"""
    <time
      id={@id}
      phx-hook="LocalTimeHook"
      {@rest}
      class={[@class, "opacity-0 transition-opacity duration-200"]}
      data-format={@format}
      data-locale={@locale}
      data-preset={@preset}
    >
      <%= @for %>
    </time>
    """
  end
end
