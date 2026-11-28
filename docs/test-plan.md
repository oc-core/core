<!--
SPDX-FileCopyrightText: 2026 Open Communities Core contributors
SPDX-License-Identifier: CC-BY-4.0
-->

# Interoperability test plan

- Status: Draft
- Version: 0.1
- Date: 2026-11-28
- Editor: Adrian Boros
- Tests against: [governance policy](specs/governance-policy.md) 0.1,
  [community archive](specs/community-archive.md) 0.1, [privacy modes](specs/privacy-modes.md)
  0.1, [adapter capabilities](specs/capabilities.md) 0.1, and ADRs
  [0008](adr/0008-participant-profiles-and-grants.md) and
  [0009](adr/0009-modules-and-templates.md)

**No test in this plan has been run.** The plan says what will be tested, how a result is judged
and where results are recorded. It is written before the implementation so that the tests are
not shaped by what the code happens to do.

## 1. Purpose

OCC makes four claims that can be checked from outside:

1. a community on an OCC node can be found and followed from another ActivityPub server, and
   what it publishes arrives there;
2. a community can move from one OCC node to another with its rules, its history of decisions
   and its members, and nothing arrives that the members did not release;
3. control of a community changes hands only as its policy allows, and the members are told;
4. a community that is private stays private, in every one of the cases above.

This plan gives each claim tests with an identifier and an acceptance criterion. It also lists
the conformance checks for each specification, so that a second implementation can use them.

## 2. How a result is judged

Every test has a class.

| Class | Meaning |
|---|---|
| **Required** | the claim is not made until the test passes |
| **Required, blocking** | as above, and a failure stops the release of anything that depends on it, whatever else passes. All privacy tests have this class |
| **Experiment** | the outcome depends on software this project does not control. The test is done when it has been run and its result recorded precisely, whatever the result |

A run has one verdict.

| Verdict | Meaning |
|---|---|
| `pass` | every acceptance criterion was observed |
| `partial` | some criteria were observed; the record lists which were not, and why |
| `fail` | a criterion was contradicted |
| `blocked` | the test could not be run; the record says what was missing |

A negative result of an experiment is a finding and is published like any other. A `partial` or
`fail` of a required test is never recorded as a limitation and left there: the claim it
supports is withdrawn from the documentation until the test passes.

## 3. Environment

| Part | What it is |
|---|---|
| **OCC A**, **OCC B** | two OCC nodes with separate databases, keys and host names, built from the same commit unless a test says otherwise |
| **Mastodon** | one Mastodon instance run by the project inside the lab; the version is recorded with each run |
| **Drupal** | one Drupal site with its ActivityPub module, for T6 only |
| **Observer** | a recorder between the servers that keeps every request and response, used to check what was and was not sent |

Rules for the lab:

- Synthetic accounts and synthetic data only. No real person's data is used at any point.
- No test is run against a server the project does not operate.
- The lab is started from this repository with one command, so that anyone can repeat a run.
- A privacy test inspects the observer's record, the public endpoints and the server logs, not
  only the user interface.

## 4. Scenario tests

"Covers" names the sections a test exercises. GP is the governance policy specification, CA the
community archive, PM privacy modes and AC adapter capabilities.

### 4.1 Federation

| ID | Scenario | Passes when | Covers | Class |
|---|---|---|---|---|
| T1 | A `federated` community on OCC A is looked up and followed from Mastodon | the handle resolves through WebFinger; the actor document is accepted by Mastodon and contains only what the privacy modes specification allows in an actor document (PM §5.3); `Follow` is answered with `Accept`; the follower is recorded on both sides; the followers collection lists nothing to an unauthenticated requester | PM §5.3, §5.4 | Required |
| T2 | A member with `privacy.publish` creates a public item, edits it, then retracts it | `Create`, `Update` and `Delete` reach the follower's inbox and Mastodon shows, updates and removes the item; the payload names the community actor and no member; a reply, mention, like and share sent from Mastodon are discarded and not stored; a `privacy.published` and a `privacy.retracted` entry are in the governance log | PM §5.4, §6, §7.6 | Required |

### 4.2 Privacy

| ID | Scenario | Passes when | Covers | Class |
|---|---|---|---|---|
| T7 | A `private` community exists on a node with federation switched on, next to a `federated` one, while T1, T2 and T5 are run | no actor, no WebFinger entry and no outbound request exists for it; a discovery request and an inbound activity for it are answered exactly as for a name that does not exist, in status and body; no field of it appears in any federation payload, public endpoint, error message, redirect, address or the node's description of itself | PM §5.1 (P1 to P8), §5.2 | Required, blocking |
| T10 | Synthetic records about members and about represented persons, including minors, are placed in a community in each mode; every federation and export path is exercised | no such record, name, count or role appears in a federation payload or at a public endpoint in any mode; a structure archive contains no direct identifier of a person; a member's data leaves only in that member's released parcel; who is responsible for personal data before, during and after a move is written down for each move scenario | PM §5.1 (P1 to P4), CA §2, §4, §5, §9 | Required, blocking |
| T11 | A `federated` community changes to `discoverable`, then to `private`; later a more open change is proposed | each stricter change takes effect at once: a `Delete` is sent for every public item and then for the actor, public addresses stop answering, followers are removed, and the community is never told that remote copies are gone; the more open change takes effect only after the notice of PM §7.3 and its log entries | PM §7.2 to §7.4, §7.6 | Required, blocking |

### 4.3 Community portability

| ID | Scenario | Passes when | Covers | Class |
|---|---|---|---|---|
| T5 | A community moves from OCC A to OCC B: pre-flight report, structure archive, import, then member parcels | the report is produced before anything is written and the move carries exactly what it said; the archive validates; on B the identifier, structure, roles, policy and governance log are identical and the log continues with the next `seq`; each membership is awaiting its member until that member's parcel arrives; an item whose author did not release a parcel is unavailable and is not filled from elsewhere; an altered file, a broken log chain or a second import of the same community is refused and nothing is created | CA §3 to §10, AC §7, §8, GP §10 | Required |
| N02 | The same move, seen from outside | the community identifier is unchanged while node and address changed; at no moment do both nodes accept writes for it; members regain access on B through their own membership and not through a copy of their account | CA §7.1, §10 | Required, part of T5 |
| N07 | The move is interrupted: after export, during import, with concurrent changes on A, and with A unreachable | for each case the record says whether the move can be resumed or must be restarted; a failed import leaves nothing behind; there are never two nodes acting for the community | CA §10 | Experiment |
| N06 | The move is made between nodes run by two different operators | rules, permitted data and member access are preserved; nothing about any other community on either node is visible to the other operator | CA §10, PM §5.1 (P8) | Experiment |
| T12 | A `federated` community moves to a node that supports `private` only | the importer says so before creating anything; if the move goes ahead the community arrives as `private` with a `privacy.changed` entry giving the reason `unsupported_mode`, and no actor is created | PM §8.1, §8.2, AC §8.2 | Required |

### 4.4 Governance

| ID | Scenario | Passes when | Covers | Class |
|---|---|---|---|---|
| T8 | Control of a community is transferred under each mode's policy; then attempts are made by a member without `transfer.propose`, to a target that cannot hold the role, and with an approval that cannot be reached | the transfer passes through every state of GP §8.1 in order and takes effect only after acceptance and the notice period; every member is told what G1 requires and can leave and export during the notice; content keeps its earlier audience; each refused, withdrawn or expired attempt leaves policy, members, roles and delegations exactly as before, with an entry in the governance log | GP §6, §7, §8, §10 | Required |
| T13 | The transferred community of T8 is then moved as in T5 | on OCC B the log replays to the same policy, and no role, delegation or permission that the log shows as ended is in force | GP §10, CA §8, §10 | Required |

### 4.5 Security

| ID | Scenario | Passes when | Covers | Class |
|---|---|---|---|---|
| T9 | Inbound activities with a missing, invalid or expired signature, a signature by a key other than the claimed actor's, a replayed activity, and a `Delete` of an actor sent by someone else | each is rejected or ignored, changes no state, and is answered without revealing whether a community exists; a request for a member-only resource without a session is refused in the same way for an existing and a missing community | PM §5.2, §5.4 | Required |

### 4.6 Nodes

| ID | Scenario | Passes when | Covers | Class |
|---|---|---|---|---|
| N01 | One node hosts two communities with separate controllers and members | no read, write or enumeration crosses from one to the other, through the interface, the API or a crafted identifier; a query that is not scoped to a community cannot be written | PM §5.1 (P8) | Required |
| N03 | A node with federation switched off and no outbound network | a community is created, members are invited, control is transferred, the community is exported and imported again; the observer records no outbound request | PM §5.1 (P9), §8.1 | Required |
| N04 | A fresh installation on a minimal server, a backup, a restore to an empty server, and an upgrade | the time to install is measured and published; after the restore identifiers, memberships, policy and governance log are identical; the upgrade can be rolled back | (none) | Required |

### 4.7 Experiments with other software

| ID | Scenario | Passes when | Covers | Class |
|---|---|---|---|---|
| T3 | A `federated` community followed from Mastodon moves from OCC A to OCC B and announces the new actor with `Move` | the record states whether Mastodon followed the new actor in place of the old one, after how long, and what a follower saw; the report for the move showed `identity.actor_move` and `graph.followers` as `partial` with `remote_dependent` | PM §8.3, AC §5.2 | Experiment |
| T4 | `Move` between a community actor and a Mastodon account, in each direction, and the import of a Mastodon account export as content | the record states what each side accepted and what it refused; imported items are shown as imported with their origin, take the audience the importing adapter declared, and are never sent as if they were new | AC §5.2, §12 | Experiment |
| T6 | T1 and T2 against a Drupal site with its ActivityPub module | the record states what worked and what did not, with the versions used | PM §5.3, §5.4 | Experiment |

## 5. Tests for participant profiles and optional modules

These follow from ADR 0008 and ADR 0009. They are defined here and are scheduled with the first
optional module; until then none can be run. All are **Required**; PP07 is **blocking**.

| ID | Case | Passes when |
|---|---|---|
| PP01 | two communities on one node hold a profile for the same person | neither can read, list or infer the other's profile |
| PP02 | a grant for one action on one participant | the holder can do that action and sees no record, media, conversation or balance |
| PP03 | an expired or withdrawn grant | it cannot be used; the refusal is explained from the grant |
| PP04 | two participants with the same representative, a grant on one | it never covers the other |
| PP05 | a representative proposes another adult | nothing is granted until the responsible role confirms; a refusal leaves no access |
| PP06 | an account is linked to an existing profile | identifier and records are unchanged; no link without the representative's confirmation; existing grants are listed for review |
| PP07 | any privacy mode, federation switched on | no actor, no WebFinger entry and no payload mentions a profile (extends T7 and T10; PM §5.1, P3) |
| PP08 | a move from OCC A to OCC B | profiles and grants arrive only in the member stage; grant holders regain access through their own membership (extends N02) |

| ID | Case | Passes when |
|---|---|---|
| MT01 | a node built with no module | every test of section 4 passes; a community is created from the minimal preset |
| MT02 | a module enabled in one community and not in another on one node | the second community has no route, record or right from it |
| MT03 | a member without the right tries to enable a module | refused; nothing is logged as enabled |
| MT04 | a module is disabled | no new writes; existing records remain and can be exported; the governance log holds the change |
| MT05 | an invalid preset is registered | rejected with the failing rule; no community can be created from it |
| MT06 | a preset is updated after a community was created from it | the community is unchanged until a governed change applies the new version |
| MT07 | a setup is finished with no question answered | the community works with the defaults |
| MT08 | an archive is imported on a node that lacks one of its modules | the report has an `extension_missing` finding before any data is written; if the import goes ahead the module's files are kept unchanged, exported unchanged and shown to nobody (CA §11, AC §8.2) |

## 6. Conformance groups

One group per specification. A group can be run against any implementation, without a second
server. Each group has the same four parts:

| Part | Check |
|---|---|
| a | every published example validates against its schema |
| b | a set of invalid variants, each breaking one rule, is rejected by the schema |
| c | each rule the specification lists as one a schema cannot express is enforced by the validator, with one accepted and one rejected case per rule |
| d | the digest of a document is the SHA-256 of its RFC 8785 canonical form, and two implementations compute the same value for the published examples |

| ID | Specification | Schema-inexpressible rules (part c) | Further checks |
|---|---|---|---|
| CG-GP | governance policy | GP §12, rules 1 to 8 | the mode constraints of GP §7; an approval rule of each type reaches and fails to reach its requirement (GP §6); a recovery rule is required where GP §9.2 says so |
| CG-CA | community archive | the checks of CA §8 (rule 4) and §10 | every file is listed with its hash, size and transfer class; nothing `personal` is in a structure archive (CA §5); the published sample imports |
| CG-PM | privacy modes | PM §12, rules 1 to 7 | each row of PM §5.2 to §5.4; a node refuses a mode it does not support (PM §8.1) |
| CG-AC | adapter capabilities | AC §11, rules 1 to 7 | the comparison rule of AC §7 yields the published report from the published declarations; a `blocked` move is not carried out and a `partial` one needs the report to have been shown (AC §8.4) |

The groups become part of this repository's test suite with the first implementation of each
specification.

## 7. Records

Each run is recorded as one file in `docs/research/compat/`, named `<id>-<date>.yml`:

```yaml
id: T1
date: 2026-11-28
occ_version: 0.1.0-dev+<commit>
counterpart: mastodon 4.x
federation_library: <name and version>
expected: ...
observed: ...
limitation: ...
verdict: pass | partial | fail | blocked
```

A compatibility table is generated from these files and published with the documentation. It
shows the latest verdict for each test and each counterpart version, including the negative
ones.

## 8. Not covered by this plan

- **Other ActivityPub servers.** The claim is about Mastodon and about two OCC nodes. The Drupal
  module is an experiment. Nothing is claimed about any other server.
- **Member accounts as federated actors.** The specifications define no member actor in version
  0.1, so there is nothing to test.
- **Node failure and failover**: loss of a process, a partition, a regional outage. N04 covers
  backup and restore only.
- **Payments.** The module of ADR 0006 is not designed in detail yet; its tests are written with
  it.
- **Load and performance.**
- **How a community's identifier is bound to keys**, which the community archive specification
  does not define in version 0.1 (CA §14).

## 9. Changes to this plan

A test is added, changed or withdrawn by pull request. A test that has a recorded run is not
renumbered, and a withdrawn identifier is not used again.
