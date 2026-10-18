<!--
SPDX-FileCopyrightText: 2026 Open Communities Core contributors
SPDX-License-Identifier: CC-BY-4.0
-->

# 0001 — Technology stack and architectural boundaries

- Status: Proposed
- Date: 2026-10-18
- Deciders: Adrian Boros

## Context and problem statement

Open Communities Core is infrastructure for many independently owned communities that need to
talk to each other, run in real time, and move between servers. It must run on its own, support
private-by-default communities, federate over ActivityPub when asked to, and let a community be
exported and imported with its governance intact. Which language, framework, storage and
architecture should the reference implementation use, and how should federation relate to the
core model?

## Decision drivers

- Many concurrent connections and real-time messaging per community.
- Background work for federation delivery and portability that must not block requests.
- Fault isolation between communities and between the core and the federation layer.
- Private communities must be unreachable from the federation layer by construction.
- A small team: the architecture must stay simple to operate (no microservices at the start).
- An existing Elixir ActivityPub ecosystem (Bonfire, the Pleroma/Akkoma lineage).
- Contributor accessibility and long-term maintainability.

## Considered options

1. Elixir and Phoenix on the Erlang VM, PostgreSQL, modular umbrella.
2. TypeScript and Node.js.
3. Go.
4. Rust.
5. Bonfire as the base platform rather than a library.

## Decision outcome

**Option 1, accepted provisionally**, with the following table:

| Component | Decision | Status |
|---|---|---|
| Language and runtime | Elixir on Erlang/OTP | accepted provisionally |
| Web framework | Phoenix, JSON API; no LiveView for product interfaces (admin tooling may use it) | accepted provisionally |
| Database | PostgreSQL with Ecto | accepted provisionally |
| Background processing | Oban | accepted provisionally |
| Real-time | Phoenix Channels | accepted provisionally |
| Architecture | modular umbrella with hexagonal boundaries; contexts inside `occ_core`; a context becomes its own application only when it needs independent dependencies or operations | accepted |
| Federation | adapter-based; the domain model does not depend on ActivityPub | accepted |
| ActivityPub implementation | Bonfire `activity_pub` library | under evaluation (see `docs/research/bonfire-evaluation.md`) |
| Bonfire as base platform | — | not selected; kept as an alternative in the evaluation |
| API | versioned HTTP JSON API with OpenAPI description | accepted |
| Clients | web in React and TypeScript; mobile in React Native | preferred direction, outside this repository |
| Deployment | Docker, self-hosting first | accepted |
| Native OCC-to-OCC protocol; concrete portability mechanisms | — | deferred to later ADRs |

Central principle: **OCC owns the canonical model** for identity, communities, memberships,
permissions and governance. ActivityPub is an external protocol handled by an adapter, not the
internal data model. Distributed governance (several parties administering one community) is
independent of distributed infrastructure (several instances); the first works inside one
instance, the second is built on top.

### Consequences

- Good: the BEAM gives concurrency, isolation and fault tolerance without microservices;
  Phoenix Channels cover real-time; Oban covers queues on the same database.
- Good: the adapter boundary makes "private communities never federate" a structural property.
- Bad: a smaller contributor pool than TypeScript; mitigated with clear API contracts, SDKs in
  other languages, and specifications that do not depend on Elixir.
- Bad: if the Bonfire library cannot sit behind the adapter boundary, federation has to be
  written in-house; the evaluation is time-boxed to find out early.

## Pros and cons of the options

**Elixir / Phoenix.** Pro: concurrency, reliability, real-time, the richest ActivityPub
ecosystem outside Ruby and PHP. Con: smaller ecosystem for some integrations.

**TypeScript / Node.js.** Pro: largest ecosystem, fastest initial development. Con: more
application-level work for concurrency and isolation; weaker fit for long-lived stateful
connections at scale.

**Go.** Pro: efficient, simple deployment. Con: less integrated real-time framework; federation
libraries less mature.

**Rust.** Pro: performance and memory safety. Con: development cost for a small team.

**Bonfire as base platform.** Pro: existing federation and social features. Con: inherits its
architecture and identity model; OCC's ownership and portability model may not fit; OCC would be
an extension rather than infrastructure.

## More information

- Bonfire evaluation: `docs/research/bonfire-evaluation.md`.
- The licence choice (AGPL-3.0-or-later) is compatible with using the Bonfire library and is
  recorded in `LICENSE` and `CONTRIBUTING.md`.
