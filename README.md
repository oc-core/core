<!--
SPDX-FileCopyrightText: 2026 Open Communities Core contributors
SPDX-License-Identifier: CC-BY-4.0
-->

# Open Communities Core

[![CI](https://github.com/oc-core/core/actions/workflows/ci.yml/badge.svg)](https://github.com/oc-core/core/actions/workflows/ci.yml)
[![REUSE status](https://api.reuse.software/badge/github.com/oc-core/core)](https://api.reuse.software/info/github.com/oc-core/core)
[![License: AGPL-3.0-or-later](https://img.shields.io/badge/license-AGPL--3.0--or--later-blue.svg)](LICENSE)
![Status: pre-alpha](https://img.shields.io/badge/status-pre--alpha-orange.svg)

Open-source infrastructure for community ownership, identity, privacy, federation and
portability.

**Status: pre-alpha.** The repository holds the architecture, the decision records and an
application skeleton. There is no usable release yet.

## What it is

Open Communities Core (OCC) lets people and organisations create, administer, transfer and move
private digital communities, whether the initiative comes from an institution or from the
members themselves. It answers one question in software:

> Who has the right to decide what happens to a community, how do they acquire that right, and
> how can they lose or transfer it?

OCC owns the canonical model for identity, communities, membership, roles, policies and
governance. Federation (ActivityPub) and portability are adapters on top of that model, never its
source of truth. A community can be fully private and never touch the Fediverse, or it can choose
to be discoverable or federated.

## Principles

1. A community can exist without any organisation, permanently.
2. No administrator can transfer control unilaterally in every situation; control is a policy,
   not an owner column.
3. A community can leave one OCC instance for another, keeping its structure, members, roles,
   rules and history, with each member's consent handled explicitly.
4. OCC installs and runs on its own, with no account or service from any particular vendor.

## Architecture in one paragraph

An Elixir umbrella: `occ_core` holds the domain (`OCC.Identity`, `OCC.Communities`,
`OCC.Membership`, `OCC.Governance`, `OCC.Policies`, `OCC.Portability`, `OCC.Federation`);
`occ_core_web` is the JSON API. PostgreSQL through Ecto, Oban for background work, Phoenix
Channels for real-time. See [`docs/adr/`](docs/adr/) for the decisions and
[`docs/research/`](docs/research/) for experiment write-ups.

## Quick start (development)

Requirements: Erlang/OTP 29, Elixir 1.20 (see `.tool-versions`), PostgreSQL 16 (or Docker).

```bash
git clone https://github.com/oc-core/core.git
cd core
docker compose up -d        # PostgreSQL on localhost:5432 (set OCC_DB_PORT in .env if taken)
mix setup                   # deps, database, migrations
mix test
mix phx.server              # http://localhost:4000
```

`mix lint` runs formatting, Credo, Sobelow and the dependency audit; `mix precommit` runs what CI
runs.

## Roadmap

| Milestone | Content |
|---|---|
| M1 | Architecture, governance policy model, community archive specification, interoperability test plan |
| M2 | Community lifecycle, membership, roles and permissions, governance transfer with an auditable log, JSON API |
| M3 | ActivityPub adapter (WebFinger, actors, signatures, Follow, public notes), account migration via `Move`, migration orchestrator |
| M4 | OCC-to-OCC community portability, privacy test suite, reference deployment, documentation |

Progress and the public compatibility matrix are tracked in the issue tracker and in
[`docs/research/`](docs/research/).

## Contributing

Contributions are welcome under the Developer Certificate of Origin. Read
[CONTRIBUTING.md](CONTRIBUTING.md) first; it covers sign-off, commit messages, the pull request
process and the policy on AI assistance. Everyone participating is expected to follow the
[Code of Conduct](CODE_OF_CONDUCT.md). Security issues go through [SECURITY.md](SECURITY.md),
not the public tracker.

## Licence

Code is licensed under the GNU Affero General Public License v3.0 or later
([LICENSE](LICENSE)). Documentation is CC-BY-4.0. The repository follows the
[REUSE](https://reuse.software/) specification; see `REUSE.toml` and `LICENSES/`.

Open Communities Core is maintained by its contributors. The first application built on it is
Kidgarten, a platform for early-education communities.
