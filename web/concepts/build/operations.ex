defmodule Juggler.BuildOperations do
  alias Juggler.Repo
  alias Juggler.User
  import Comeonin.Bcrypt
  import Plug.Conn
  import Monad.Result, only: [success?: 1,
                              unwrap!: 1,
                              success: 1,
                              error: 1]


end
