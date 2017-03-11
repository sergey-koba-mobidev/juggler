defmodule Juggler.UserView do
  use Juggler.Web, :view
  import Exgravatar
  alias Juggler.{Repo, Subscription}

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

  def plan_name(user) do
    subscription = Repo.get_by!(Subscription, user_id: user.id)
    String.capitalize(subscription.plan)
  end
end
