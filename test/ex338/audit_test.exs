defmodule Ex338.AuditTest do
  use Ex338.DataCase, async: true

  alias Ex338.Audit
  alias Ex338.Audit.AuditLog

  describe "log/1" do
    test "records a valid entry" do
      user = insert(:user)

      assert {:ok, %AuditLog{} = entry} =
               Audit.log(%{
                 user_id: user.id,
                 source: "mcp",
                 action: "waiver.create",
                 resource_type: "Waiver",
                 resource_id: 42,
                 outcome: "success",
                 metadata: %{token_name: "Claude MCP"}
               })

      assert entry.user_id == user.id
      assert entry.source == "mcp"
      assert entry.outcome == "success"
      assert entry.metadata["token_name"] == "Claude MCP"
    end

    test "rejects an invalid source or outcome" do
      assert {:error, changeset} =
               Audit.log(%{source: "carrier-pigeon", action: "x", outcome: "success"})

      assert %{source: _} = errors_on(changeset)

      assert {:error, changeset} =
               Audit.log(%{source: "api", action: "x", outcome: "maybe"})

      assert %{outcome: _} = errors_on(changeset)
    end

    test "requires source, action, and outcome" do
      assert {:error, changeset} = Audit.log(%{})
      errors = errors_on(changeset)
      assert errors[:source]
      assert errors[:action]
      assert errors[:outcome]
    end
  end

  describe "outcome_for/1" do
    test "maps result tuples to outcome strings" do
      assert Audit.outcome_for({:ok, %{}}) == "success"
      assert Audit.outcome_for({:error, :forbidden}) == "denied"
      assert Audit.outcome_for({:error, :not_found}) == "error"
      assert Audit.outcome_for({:error, %Ecto.Changeset{}}) == "error"
    end
  end

  describe "queries" do
    test "list_for_user/2 returns only that user's entries, newest first" do
      user = insert(:user)
      other = insert(:user)
      Audit.log(%{user_id: user.id, source: "api", action: "a.1", outcome: "success"})
      Audit.log(%{user_id: user.id, source: "api", action: "a.2", outcome: "success"})
      Audit.log(%{user_id: other.id, source: "api", action: "b.1", outcome: "success"})

      actions = Enum.map(Audit.list_for_user(user.id), & &1.action)

      assert actions == ["a.2", "a.1"]
    end

    test "list_for_resource/2 filters by resource" do
      user = insert(:user)

      Audit.log(%{
        user_id: user.id,
        source: "api",
        action: "waiver.create",
        resource_type: "Waiver",
        resource_id: 7,
        outcome: "success"
      })

      Audit.log(%{
        user_id: user.id,
        source: "api",
        action: "waiver.create",
        resource_type: "Waiver",
        resource_id: 9,
        outcome: "success"
      })

      assert [entry] = Audit.list_for_resource("Waiver", 7)
      assert entry.resource_id == 7
    end
  end
end
