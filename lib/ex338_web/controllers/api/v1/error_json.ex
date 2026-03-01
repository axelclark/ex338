defmodule Ex338Web.Api.V1.ErrorJSON do
  def error(%{message: message}) do
    %{error: message}
  end
end
