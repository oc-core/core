# SPDX-FileCopyrightText: 2026 Open Communities Core contributors
# SPDX-License-Identifier: AGPL-3.0-or-later

defmodule OCCWeb.Application do
  # See https://elixir.hexdocs.pm/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      OCCWeb.Telemetry,
      # Start a worker by calling: OCCWeb.Worker.start_link(arg)
      # {OCCWeb.Worker, arg},
      # Start to serve requests, typically the last entry
      OCCWeb.Endpoint
    ]

    # See https://elixir.hexdocs.pm/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: OCCWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    OCCWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
