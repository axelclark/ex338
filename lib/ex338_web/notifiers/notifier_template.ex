defmodule Ex338Web.NotifierTemplate do
  @moduledoc false

  import Swoosh.Email

  def plain_text(data) do
    new()
    |> bcc(data.bcc)
    |> cc(data.cc)
    |> from(data.from)
    |> subject(data.subject)
    |> text_body(data.message)
  end
end
