defmodule Ex338.WaiverTest do
  use Ex338.ModelCase, async: true

  alias Ex338.Waiver

  @valid_attrs %{fantasy_team_id: 1}
  @invalid_attrs %{}

  describe "changeset/2" do
    test "changeset with valid attributes" do
      changeset = Waiver.changeset(%Waiver{}, @valid_attrs)
      assert changeset.valid?
    end

    test "changeset with invalid attributes" do
      changeset = Waiver.changeset(%Waiver{}, @invalid_attrs)
      refute changeset.valid?
    end
  end

  describe "new_changeset/2" do
    test "changeset with valid attributes" do
      changeset = Waiver.new_changeset(%Waiver{}, @valid_attrs)
      assert changeset.valid?
    end

    test "changeset with invalid attributes" do
      changeset = Waiver.new_changeset(%Waiver{}, @invalid_attrs)
      refute changeset.valid?
    end
  end

  describe "set_datetime_to_process/1" do
    test "takes a changeset and add a time 3 days in future" do
      changeset = Ecto.Changeset.cast(%Waiver{}, @valid_attrs, [:fantasy_team_id])

      result = Waiver.set_datetime_to_process(changeset)

      assert result.changes.process_at > Ecto.DateTime.utc
    end
  end
end
