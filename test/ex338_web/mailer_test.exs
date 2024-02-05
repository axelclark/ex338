defmodule Ex338Web.MailerTest do
  use Ex338.DataCase, async: true

  import ExUnit.CaptureLog

  alias Ex338Web.Mailer

  require Logger

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
