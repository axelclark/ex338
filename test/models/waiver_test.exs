defmodule Ex338.WaiverTest do
  use Ex338.ModelCase, async: true

  alias Ex338.Waiver

  @valid_attrs %{status: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Waiver.changeset(%Waiver{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Waiver.changeset(%Waiver{}, @invalid_attrs)
    refute changeset.valid?
  end
end
