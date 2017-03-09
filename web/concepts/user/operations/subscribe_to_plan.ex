defmodule Juggler.User.Operations.SubscribeToPlan do
  import Monad.Result, only: [success?: 1,
                              success: 1,
                              error: 1]
  alias Juggler.User

  def call(user, plan) do
    result = Juggler.Subscription.Operations.Create.call(%{"user_id" => user.id, "plan" => plan, "state" => "active"})
    if success?(result) do
      success(user)
    else
      result
    end
  end
end
