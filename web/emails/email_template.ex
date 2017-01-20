defmodule Ex338.EmailTemplate do
  @moduledoc false

  import Swoosh.Email

  def plain_text(%{
    to: recipients,
    cc: cc,
    from: from,
    subject: subject,
    message: message
  }) do

    new()
    |> to(recipients)
    |> cc(cc)
    |> from(from)
    |> subject(subject)
    |> text_body(message)
  end
end
