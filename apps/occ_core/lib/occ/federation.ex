# SPDX-FileCopyrightText: 2026 Open Communities Core contributors
# SPDX-License-Identifier: AGPL-3.0-or-later

defmodule OCC.Federation do
  @moduledoc """
  Federation: optional adapters that represent users and communities to other servers.

  ActivityPub is one adapter among possible others. The adapter depends on the domain and never
  the reverse; communities in private mode are invisible to it by construction. Candidate for
  extraction into its own umbrella application once POC-001 settles the implementation.
  No logic yet: this module marks the boundary and documents the responsibility of the context.
  Other contexts call its public functions and never touch its schemas directly.
  """
end
