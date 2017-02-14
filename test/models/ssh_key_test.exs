defmodule Juggler.SSHKeyTest do
  use Juggler.ModelCase

  alias Juggler.SSHKey

  @valid_attrs %{data: "some content", name: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = SSHKey.changeset(%SSHKey{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = SSHKey.changeset(%SSHKey{}, @invalid_attrs)
    refute changeset.valid?
  end
end
