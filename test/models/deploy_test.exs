defmodule Juggler.DeployTest do
  use Juggler.ModelCase

  alias Juggler.Deploy

  @valid_attrs %{commands: "some content", key: "some content", state: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Deploy.changeset(%Deploy{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Deploy.changeset(%Deploy{}, @invalid_attrs)
    refute changeset.valid?
  end
end
