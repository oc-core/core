<!--
SPDX-FileCopyrightText: 2026 Open Communities Core contributors
SPDX-License-Identifier: CC-BY-4.0
-->

# Specifications

Formats and protocols that other implementations can follow without depending on this code.
They live here until they move to a dedicated `specifications` repository.

Planned, in order:

| Specification | Content | Status |
|---|---|---|
| [Governance policy](governance-policy.md) | modes, rights, approval rules, transfer of control, recovery rule, governance log; [JSON Schema](schemas/governance-policy.schema.json) and [examples](examples/) | draft 0.1 |
| [Community archive](community-archive.md) | the export format for a community: structure archive and member parcels, manifest, memberships, policy, governance log, content manifest, per-field transfer classes, integrity hashes; [JSON Schemas](schemas/community-archive/) and a [sample](examples/community-archive/) | draft 0.1 |
| [Privacy modes](privacy-modes.md) | what private, discoverable and federated permit and forbid; the privacy setting, how it is changed, notice and retraction; [JSON Schema](schemas/privacy-setting.schema.json) and [examples](examples/) | draft 0.1 |
| Adapter capabilities | the capability declaration a federation or portability adapter publishes | planned |

Each specification states its relation to W3C ActivityPub and ActivityStreams and to the SWICG
data-portability work, and what is intentionally out of scope. Specification text is CC-BY-4.0;
schemas and sample code are Apache-2.0.
