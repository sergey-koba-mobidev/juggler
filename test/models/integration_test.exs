defmodule Juggler.IntegrationTest do
  use Juggler.ModelCase

  alias Juggler.Integration

  @valid_attrs %{data: %{}, key: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Integration.changeset(%Integration{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Integration.changeset(%Integration{}, @invalid_attrs)
    refute changeset.valid?
  end
end
