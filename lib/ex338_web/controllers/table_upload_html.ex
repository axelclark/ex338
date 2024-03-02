defmodule Ex338Web.TableUploadHTML do
  use Ex338Web, :html

  def new(assigns) do
    ~H"""
    <.two_col_form
      :let={f}
      for={%{}}
      as={:table_upload}
      multipart={true}
      action={~p"/table_upload"}
      show_form_error={false}
    >
      <:title>
        Upload Data from CSV Spreadsheet
      </:title>
      <:description>
        Select a database table and corresponding CSV file from your computer to upload data
      </:description>

      <.input
        field={f[:table]}
        label="Table to Upload"
        type="select"
        required
        options={@table_options}
        prompt="Select a table to upload"
      />

      <.input field={f[:spreadsheet]} label="Upload Spreadsheet" type="file" />

      <:actions>
        <.submit_buttons back_route={~p"/"} submit_text="Upload" />
      </:actions>
    </.two_col_form>
    """
  end
end
