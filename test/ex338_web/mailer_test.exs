defmodule Ex338Web.MailerTest do
  use Ex338.DataCase, async: true

  import ExUnit.CaptureLog
  require Logger

  alias Ex338Web.Mailer

  describe "handle_delivery/1" do
    test "logs an error email" do
      delivery = {:error, {:error, "reason"}}
      expected_msg = "reason"

      assert capture_log(fn ->
               Mailer.handle_delivery(delivery)
             end) =~ expected_msg
    end
  end
end
