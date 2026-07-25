defmodule Ex338Web.Api.V1.ErrorJSON do
  def error(%{message: message}) do
    %{error: message}
  end

  def changeset_error(%{changeset: changeset}) do
    errors =
      Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
        Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
          opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
        end)
      end)

    %{error: "Validation failed", errors: errors}
  end
end
