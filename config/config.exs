# SPDX-FileCopyrightText: 2026 Open Communities Core contributors
# SPDX-License-Identifier: AGPL-3.0-or-later

# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of the Config module.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
import Config

# Background processing: federation delivery and portability jobs run outside the request path.
config :occ_core, Oban,
  repo: OCC.Repo,
  engine: Oban.Engines.Basic,
  notifier: Oban.Notifiers.Postgres,
  queues: [default: 10, federation: 10, portability: 5],
  plugins: [{Oban.Plugins.Pruner, max_age: 60 * 60 * 24 * 7}]

# Configure Mix tasks and generators
config :occ_core,
  namespace: OCC,
  ecto_repos: [OCC.Repo]

config :occ_core_web,
  namespace: OCCWeb,
  ecto_repos: [OCC.Repo],
  generators: [context_app: :occ_core, binary_id: true]

# Configures the endpoint
config :occ_core_web, OCCWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: OCCWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: OCC.PubSub,
  live_view: [signing_salt: "aDHZOnGO"]

# Configure Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
