defmodule Juggler.User.Operations.CreateQueue do
  import Monad.Result, only: [success: 1,
                              error: 1]

  def call(user) do
    Verk.add_queue(String.to_atom("user_" <> Integer.to_string(user.id)), Juggler.Subscription.Operations.GetWorkersCount.call(user))
    success(user)
  end
end
