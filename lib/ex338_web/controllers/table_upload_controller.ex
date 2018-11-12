defmodule Ex338Web.TableUploadController do
  use Ex338Web, :controller
  alias Ex338.{Uploader}

  def new(conn, _params) do
    render(conn, "new.html", table_options: Uploader.table_options())
  end

  def create(conn, %{"table_upload" => table_params}) do
    file = table_params["spreadsheet"]
    module = table_params["table"]

    case Uploader.insert_from_csv(file.path, module) do
      {:ok, results} ->
        conn
        |> put_flash(:info, "Uploaded #{Enum.count(results)} records to #{module} successfully")
        |> redirect(to: table_upload_path(conn, :new))

      {:error, _, changeset, _} ->
        conn
        |> put_flash(:error, "There was an error during the upload: #{inspect(changeset.errors)}")
        |> render("new.html", table_options: Uploader.table_options())
    end
  end
end
