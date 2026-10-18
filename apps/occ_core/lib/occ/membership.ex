# SPDX-FileCopyrightText: 2026 Open Communities Core contributors
# SPDX-License-Identifier: AGPL-3.0-or-later

defmodule OCC.Membership do
  @moduledoc """
  Membership: how individuals and organisations relate to a community.

  Invitations, acceptance, leaving and removal. Membership is distinct from the ActivityPub
  Follow relation: a remote follower of a community's public actor is not a member.
  No logic yet: this module marks the boundary and documents the responsibility of the context.
  Other contexts call its public functions and never touch its schemas directly.
  """
end
