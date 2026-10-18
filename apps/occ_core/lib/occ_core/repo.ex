# SPDX-FileCopyrightText: 2026 Open Communities Core contributors
# SPDX-License-Identifier: AGPL-3.0-or-later

defmodule OCC.Repo do
  use Ecto.Repo,
    otp_app: :occ_core,
    adapter: Ecto.Adapters.Postgres
end
