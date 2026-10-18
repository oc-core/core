# SPDX-FileCopyrightText: 2026 Open Communities Core contributors
# SPDX-License-Identifier: AGPL-3.0-or-later

import Config

# Jobs run inline in tests; no queues, no plugins.
config :occ_core, Oban, testing: :inline

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :occ_core, OCC.Repo,
  username: "postgres",
  password: "postgres",
  hostname: System.get_env("OCC_DB_HOST", "localhost"),
  port: String.to_integer(System.get_env("OCC_DB_PORT", "5432")),
  database: "occ_core_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :occ_core_web, OCCWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "PbkX4wndlT09NDO9MJld/Vp1PpUMMJsCVg6hBFGHkCkIfGgFF7FdUiB0rKlWNyyC",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Sort query params output of verified routes for robust url comparisons
config :phoenix,
  sort_verified_routes_query_params: true
