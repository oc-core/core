# SPDX-FileCopyrightText: 2026 Open Communities Core contributors
# SPDX-License-Identifier: AGPL-3.0-or-later

defmodule OCC.Identity do
  @moduledoc """
  Identity: users and organisations, independent of any federated representation.

  Owns user identities and organisation identities. A user or an organisation exists without an
  ActivityPub actor; the federated actor is an optional representation managed by
  `OCC.Federation` under explicit policy. Knows nothing about communities.
  No logic yet: this module marks the boundary and documents the responsibility of the context.
  Other contexts call its public functions and never touch its schemas directly.
  """
end
