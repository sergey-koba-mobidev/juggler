defmodule Juggler.Subscription.Operations.GetWorkersCount do
  alias Juggler.{Repo, Subscription}

  def call(user) do
    subscription = Repo.get_by!(Subscription, user_id: user.id)
    module = Module.concat(Juggler.Plan, String.capitalize(subscription.plan))
    apply(module, :workers_count, [])
  end
end
