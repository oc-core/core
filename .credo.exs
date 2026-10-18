# SPDX-FileCopyrightText: 2026 Open Communities Core contributors
# SPDX-License-Identifier: CC0-1.0
%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["apps/*/lib/", "apps/*/test/", "config/", "mix.exs", "apps/*/mix.exs"],
        excluded: [~r"/_build/", ~r"/deps/", ~r"/priv/"]
      },
      plugins: [],
      requires: [],
      strict: true,
      parse_timeout: 5000,
      color: true,
      checks: %{
        extra: [
          {Credo.Check.Design.TagTODO, [exit_status: 0]}
        ]
      }
    }
  ]
}
