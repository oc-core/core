# SPDX-FileCopyrightText: 2026 Open Communities Core contributors
# SPDX-License-Identifier: AGPL-3.0-or-later

defmodule OCC.Governance do
  @moduledoc """
  Governance: who decides what happens to a community, and how that right is acquired, lost or transferred.

  Governance modes (individual, institutional, shared, collective, transitional) and the
  transfer process: proposal, verification of rights, approvals, acceptance of responsibility
  and an append-only governance log that travels with the community on export. There is no
  owner column; control is whatever the current policy grants.
  No logic yet: this module marks the boundary and documents the responsibility of the context.
  Other contexts call its public functions and never touch its schemas directly.
  """
end
