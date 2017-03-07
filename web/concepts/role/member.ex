defmodule Juggler.Role.Member do
  # to succeed controller,action should match any allow, and shouldn't match any deny
  def allow do
    [
      {"project", "show"},
      {"build", ".*"},
      {"deploy", ".*"}
    ]
  end

  def deny do
    []
  end
end
