<!--
SPDX-FileCopyrightText: 2026 Open Communities Core contributors
SPDX-License-Identifier: CC-BY-4.0
-->

# Third-party dependencies

Every runtime dependency with its licence, checked for compatibility with AGPL-3.0-or-later
before it is added. Development-only tools are listed for completeness.

| Package | Licence | Role | Compatible |
|---|---|---|---|
| phoenix | MIT | web framework | yes |
| phoenix_ecto | MIT | Ecto integration | yes |
| ecto_sql, ecto | Apache-2.0 | database access | yes |
| postgrex | Apache-2.0 | PostgreSQL driver | yes |
| phoenix_pubsub | MIT | pub/sub | yes |
| bandit | MIT | HTTP server | yes |
| jason | Apache-2.0 | JSON | yes |
| oban | Apache-2.0 | background jobs | yes |
| dns_cluster | Apache-2.0 | clustering | yes |
| telemetry_metrics, telemetry_poller | Apache-2.0 | telemetry | yes |
| credo (dev) | MIT | static analysis | yes |
| dialyxir (dev) | Apache-2.0 | type analysis | yes |
| sobelow (dev) | Apache-2.0 | security analysis | yes |
| mix_audit (dev) | MIT | dependency audit | yes |
| excoveralls (test) | MIT | coverage | yes |
| ex_doc (dev) | Apache-2.0 | documentation | yes |

Candidates under evaluation:

| Package | Licence | Role | Compatible |
|---|---|---|---|
| activity_pub (Bonfire) | AGPL-3.0 | ActivityPub implementation | yes, same copyleft |
