# SPDX-FileCopyrightText: 2026 Open Communities Core contributors
# SPDX-License-Identifier: AGPL-3.0-or-later

defmodule OCC.Policies do
  @moduledoc """
  Policies: roles, permissions and the rules that constrain them.

  Role grants on memberships, permission checks enforced in the domain layer (never only in the
  API), and the governance policy document that defines proposal rights, approval rules and
  recovery rules for a community.
  No logic yet: this module marks the boundary and documents the responsibility of the context.
  Other contexts call its public functions and never touch its schemas directly.
  """
end
