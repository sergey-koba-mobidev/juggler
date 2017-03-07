defmodule Juggler.Role.Admin do
  # to succeed controller,action should match any allow, and shouldn't match any deny
  def allow do
    [
      {"*", "*"}
    ]
  end

  def deny do
    [
      {"project", "delete"}
    ]
  end
end
