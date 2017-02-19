defmodule Juggler.SourceTest do
  use Juggler.ModelCase

  alias Juggler.Source

  @valid_attrs %{data: %{}, key: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Source.changeset(%Source{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Source.changeset(%Source{}, @invalid_attrs)
    refute changeset.valid?
  end
end
