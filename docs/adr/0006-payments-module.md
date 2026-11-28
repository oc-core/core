<!--
SPDX-FileCopyrightText: 2026 Open Communities Core contributors
SPDX-License-Identifier: CC-BY-4.0
-->

# 0006 — Payments as an optional module

- Status: Accepted
- Date: 2026-11-28
- Deciders: Adrian Boros

Nothing in this record is implemented yet.

## Context and problem statement

Communities collect money: dues, a shared expense, a contribution to an event, a fundraising
target. They need the same things each time: who may ask for money and who may see what was
paid, partial payments, corrections that leave a trace, and a way to match what arrived with
what was owed. Open Communities Core already has the membership and governance those rules
depend on. A community that collects nothing must still be able to run a node without payment
tables, jobs or provider credentials.

[ADR 0009](0009-modules-and-templates.md) decides where an optional capability lives. This
record decides the inside of the payments module: its parts, its boundary with payment
providers, and the order in which it is delivered.

## Decision drivers

- The core runs without payments, and a community can lack them.
- OCC never holds funds or the keys that spend them.
- A payment record identifies as few people as possible.
- A community can use the module before any payment provider is chosen.
- Payment data never reaches federation.
- A small team: one deployed release until isolation is shown to be needed.

## Considered options

1. An optional module with two contexts, providers behind adapters, delivered manual-first.
2. Payments inside `occ_core`.
3. A separately operated payment service from the start.
4. OCC holding funds or spending keys on behalf of communities.

## Decision outcome

**Option 1.**

### Packaging

Payments is an optional module under ADR 0009: a separate application of the Elixir umbrella in
this repository, depending on `occ_core`. The node operator makes it available; each community
enables it through a right in its governance policy, and the change is written to the governance
log.

Disabling the module while obligations are open is allowed, and those obligations are
**frozen**:

- they keep their state and amounts, and stay readable by the roles that could read them and by
  the membership that owes them;
- nothing new happens to them: no payment is recorded, no attempt is started, no reminder is
  sent, and a recurring issue creates nothing;
- whoever decides to disable is shown beforehand that open obligations exist;
- enabling the module again resumes them as they were. Waiving or closing a frozen obligation is
  a separate governed step, not a side effect of disabling.

### Two contexts

| Context | Owns |
|---|---|
| **Payments** | collections, obligations, splits, fundraising targets, payment records and the payment-specific permission checks, using OCC memberships and the grants of [ADR 0008](0008-participant-profiles-and-grants.md). It accepts calculated obligation lines from the caller, so the rules that compute an amount can change without changing this module |
| **Orchestrator** | provider authorisation, payment attempts, retries, settlement status and reconciliation. It runs in the same deployed release, with supervised jobs where needed. A separately operated service is considered only if deployment or failure isolation later requires it |

**An obligation belongs to a membership**, which is who owes and who pays. A line of an
obligation may carry an opaque reference to a participant profile; a payment record never needs
that person's identity. The recipient always sees which membership paid. Which participant a
line is for is resolved only inside the community, by someone permitted to read that profile.

### Providers and custody

- Payment providers sit behind adapters. OCC authorises an action within a community; the
  wallet holder or the provider authorises the spending.
- Credentials for provider calls are scoped to their purpose. Custody of funds and spending keys
  stays with the wallet holder or the provider.
- For a payment between two communities, the payer explicitly selects the recipient's wallet or
  provider endpoint. Each side keeps its own records.
- Payment data and credentials stay outside federation, in every privacy mode. No policy lifts
  this.
- Provider credentials and wallet connections never travel in a community archive. After a move
  each connection is authorised again at the destination. Obligations and payment records move
  with the community under the transfer class the module declares for them.

### Delivery

1. **Manual first.** A community issues payment requests, and authorised roles record payments
   made outside the software, including partial receipts and corrections that keep the original
   entry. This moves no money and needs no provider.
2. **Provider flows** follow when a concrete integration needs authorisation, attempts and
   reconciliation, and not before the legal position of whoever would operate them is clear.
3. **The adapter interface** is settled against a working integration, not in advance.

### Consequences

- Good: an installation that needs no payments carries no payment tables, jobs or credentials.
- Good: the first release can be used and tested before any provider decision.
- Good: a payment record does not identify a participant, who may be a minor.
- Bad: a person who holds only a payments role sees memberships and line amounts, not which
  participant a line is for, unless they may also read that profile.
- Bad: after a move every provider connection is set up again. This is deliberate.
- A disabled module leaves frozen obligations behind. They stay visible, so that a community
  cannot lose sight of money owed by switching the module off.
- The module depends on the grant check of ADR 0008 and the module declaration of ADR 0009, and
  cannot be built before both exist.

## Pros and cons of the options

**Payments inside `occ_core`.** Pro: least structure. Con: the core would not run without
payment tables and providers.

**A separately operated service from the start.** Pro: isolation. Con: more to deploy and more
ways to fail than the first release needs.

**OCC holding funds or keys.** Pro: a simpler experience for the payer. Con: custody makes every
node a target and brings obligations a community node should not carry.

Within option 1, three variants were not taken: one obligation per participant (the payment
record would identify the person); blocking the disabling of the module while obligations are
open (a community could not switch off an area it no longer wants); and pulling money
automatically on a schedule, which stays out of scope, while issuing obligations on a schedule
is kept.

## More information

Open: the adapter interface (creating a request, checking status, authorising an outgoing
payment, cancelling where the provider supports it); credential storage; the default policy for
enabling the module; the module's declaration under ADR 0009 (the actions it adds to grants, its
governance rights, its setup questions, the transfer class of each record); refunds, and how an
obligation is waived. Which providers are supported is a separate decision.

Tests that will accompany the implementation: a node built without the module passes every core
test; enabling is per community and access is scoped; a partial payment, then the rest, then a
correction leave a full trace; a recurring issue run twice creates nothing the second time;
individual amounts are invisible to members without the right; nothing payment-related appears
in a federation payload or a log; no participant identity appears in a payment record; a
duplicate notification settles nothing twice; a failed attempt never shows as paid.
