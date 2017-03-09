defmodule Juggler.Subscription.Operations.CheckActive do
  alias Juggler.{Repo, Subscription}

  def call(user) do
    subscription = Repo.get_by!(Subscription, user_id: user.id)
    subscription.state == "active"
  end
end
