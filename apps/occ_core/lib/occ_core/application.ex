# SPDX-FileCopyrightText: 2026 Open Communities Core contributors
# SPDX-License-Identifier: AGPL-3.0-or-later

defmodule OCC.Application do
  # See https://elixir.hexdocs.pm/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      OCC.Repo,
      {Oban, Application.fetch_env!(:occ_core, Oban)},
      {DNSCluster, query: Application.get_env(:occ_core, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: OCC.PubSub}
      # Start a worker by calling: OCC.Worker.start_link(arg)
      # {OCC.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: OCC.Supervisor)
  end
end
