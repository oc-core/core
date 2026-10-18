# SPDX-FileCopyrightText: 2026 Open Communities Core contributors
# SPDX-License-Identifier: AGPL-3.0-or-later

defmodule OCC.Portability do
  @moduledoc """
  Portability: export and import of communities between OCC instances.

  The OCC Community Archive (structure, memberships, roles, policies, governance log, content
  manifest with per-field transfer classes and integrity hashes) and the two-stage migration:
  structure first, then each member's confirmation under the applicable legal basis.
  No logic yet: this module marks the boundary and documents the responsibility of the context.
  Other contexts call its public functions and never touch its schemas directly.
  """
end
