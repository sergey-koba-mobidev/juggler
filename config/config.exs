# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :juggler,
  ecto_repos: [Juggler.Repo]

# Configures the endpoint
config :juggler, Juggler.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "PcMNZQFbtnQUHYfBQT3tbe2mCnIw5Rt2/+QASuJYmko6F5DGM4a8VVtTA7Sntgw6",
  render_errors: [view: Juggler.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Juggler.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
