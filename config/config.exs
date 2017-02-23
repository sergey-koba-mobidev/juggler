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

config :juggler, Juggler.Mailer,
  adapter: Bamboo.SMTPAdapter,
  server: System.get_env("SMTP_SERVER"),
  port: elem(Integer.parse(System.get_env("SMTP_PORT")), 0),
  username: System.get_env("SMTP_USERNAME"),
  password: System.get_env("SMTP_PASSWORD"),
  tls: :if_available, # can be `:always` or `:never`
  ssl: false, # can be `true`
  retries: 1

config :kerosene, theme: :semantic

config :porcelain, driver: Porcelain.Driver.Basic

config :verk, queues: [default: 2, priority: 10],
  max_retry_count: 3,
  poll_interval: 2000,
  start_job_log_level: :info,
  done_job_log_level: :info,
  fail_job_log_level: :info,
  #node_id: "1",
  redis_url: "redis://redis:6379"

config :verk_web, :authorization,
  username: {:system, "VERK_BASIC_AUTH_USERNAME"},
  password: {:system, "VERK_BASIC_AUTH_PASSWORD"},
  realm:    "Verk Web"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
