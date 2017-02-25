defmodule Juggler.DeployOutputTest do
  use Juggler.ModelCase

  alias Juggler.DeployOutput

  @valid_attrs %{event: "some content", payload: %{}}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = DeployOutput.changeset(%DeployOutput{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = DeployOutput.changeset(%DeployOutput{}, @invalid_attrs)
    refute changeset.valid?
  end
end
