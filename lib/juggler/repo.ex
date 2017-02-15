defmodule Juggler.Repo do
  use Ecto.Repo, otp_app: :juggler
  use Kerosene, per_page: 10
end
