defmodule Juggler.SSHKeysView do
  use Juggler.Web, :view

  def render("index.json", %{ssh_keys: ssh_keys}) do
    %{
      ssh_keys: Enum.map(ssh_keys, &ssh_key_json/1)
    }
  end

  def ssh_key_json(ssh_key) do
    %{
      id: ssh_key.id,
      name: ssh_key.name
    }
  end
end
