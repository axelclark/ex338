defmodule Ex338Web.CommishEmailHTML do
  use Ex338Web, :html

  alias Ex338.FantasyLeagues

  def new(assigns) do
    ~H"""
    <.two_col_form
      :let={f}
      for={@conn}
      as={:commish_email}
      action={~p"/commish_email"}
      show_form_error={false}
    >
      <:title>
        Send an email to fantasy leagues
      </:title>
      <:description>
        Select one or more leagues to send an email.
      </:description>

      <.input
        field={f[:leagues]}
        label="Select leagues to email"
        type="select"
        multiple
        options={FantasyLeagues.format_leagues_for_select(@fantasy_leagues)}
      />
      <p class="mt-2 text-sm text-gray-500" id="email-description">
        Hold CTRL (Windows) or Command (Mac) to select multiple leagues
      </p>
      <.input field={f[:subject]} label="Subject" type="text" required />
      <.input field={f[:message]} label="Message" type="textarea" required rows={6} />
      <:actions>
        <.submit_buttons back_route={~p"/"} submit_text="Send" />
      </:actions>
    </.two_col_form>
    """
  end
end
