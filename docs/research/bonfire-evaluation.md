<!--
SPDX-FileCopyrightText: 2026 Open Communities Core contributors
SPDX-License-Identifier: CC-BY-4.0
-->

# Bonfire evaluation

- Status: planned, results pending
- Date: 2026-10-18

## Question

Can OCC use the [Bonfire `activity_pub` library](https://github.com/bonfire-networks/activity_pub)
as its ActivityPub implementation behind the `OCC.Federation` adapter boundary, or should OCC
implement the protocol itself?

## What Bonfire is

[Bonfire Networks](https://bonfirenetworks.org/) is a federated community platform in Elixir and
Phoenix on PostgreSQL. Three parts matter here: the application (identity, groups, boundaries,
social features, federation, extensions), the standalone `activity_pub` library (actors,
activities, delivery, an adapter behaviour for the host application), and the federation
extension that maps Bonfire objects to activities. All are AGPL-3.0, compatible with this
repository's licence.

## Options

| Option | Description |
|---|---|
| A | Own domain and own ActivityPub adapter |
| B | OCC built as Bonfire extensions |
| C | Own domain, Bonfire `activity_pub` library behind the adapter *(starting point)* |

Option B was not selected as the starting point: OCC is infrastructure with its own identity,
ownership and portability model, and would otherwise inherit Bonfire's. It remains the
comparison point.

## Criteria

| Criterion | Weight | Measured by |
|---|---|---|
| Federation interoperability | 25 | WebFinger, actor, Follow/Accept and public Note against Mastodon 4.x; effort to get there |
| Privacy and security | 20 | private communities invisible to the library by construction; signature handling |
| Portability and ownership | 20 | no conflict with OCC's separation of user, community, organisation and federated actor |
| Architecture extensibility | 15 | the library stays behind `OCC.Federation` without leaking its schemas into the domain |
| Development effort | 10 | time to the first two tests |
| Open-source sustainability | 10 | maintenance activity, releases, documentation |

Weights are priorities, not results.

## Procedure

1. Read the library's adapter contract and data model; list its assumptions about users and
   objects.
2. Integrate it behind an `OCC.Federation.Adapter` behaviour; run actor discovery and Follow.
3. Exchange a public Note; inspect what the library stored and whether anything about a private
   community could reach it.
4. If blocked for longer than two working days, implement the same endpoints directly and
   compare.
5. Score, record the result here, and update or supersede ADR-0001.

## Results

Pending. This section will hold versions tested, the integration approach, observed behaviour,
limitations, scores and the decision.
