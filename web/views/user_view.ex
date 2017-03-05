defmodule Juggler.UserView do
  use Juggler.Web, :view
  import Exgravatar

  def render("index.json", %{users: users}) do
    %{
      users: Enum.map(users, &user_json/1)
    }
  end

  def render("show.json", %{user: user}) do
    %{
      user: user_json(user)
    }
  end

  def user_json(user) do
    %{
      id: user.id,
      name: user.name,
      email: user.email,
      avatar_url: gravatar_url(user.email)
    }
  end
end
