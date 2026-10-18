# SPDX-FileCopyrightText: 2026 Open Communities Core contributors
# SPDX-License-Identifier: AGPL-3.0-or-later

defmodule OCC.Communities do
  @moduledoc """
  Communities: lifecycle of a community as its own entity.

  Create, configure, suspend and archive communities. Records who created the community, which
  instance hosts it, which party is its data controller and which privacy mode it is in
  (private, discoverable or federated; private is the default). A community exists permanently
  without any organisation.
  No logic yet: this module marks the boundary and documents the responsibility of the context.
  Other contexts call its public functions and never touch its schemas directly.
  """
end
