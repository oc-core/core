<!--
SPDX-FileCopyrightText: 2026 Open Communities Core contributors
SPDX-License-Identifier: CC-BY-4.0
-->

# Adapter capabilities

- Status: Draft
- Version: 0.1
- Date: 2026-11-28
- Editor: Adrian Boros
- Schemas: [`schemas/capability-declaration.schema.json`](schemas/capability-declaration.schema.json),
  [`schemas/preflight-report.schema.json`](schemas/preflight-report.schema.json)
- Examples: [`examples/`](examples/), three declarations and one report

Nothing in this document is implemented yet. It is published as a draft so that it can be
reviewed before the first implementation, and it will change.

## 1. Purpose

No two systems can move the same things. An archive carries a community's rules and memberships
but no followers on other servers. ActivityPub `Move` carries followers on servers that honour
it and no data at all. An import from another platform's export file brings posts and nothing
about who may read them.

Open Communities Core does not hide these differences behind one "migrate" operation. The part
of a node that performs a move, an **adapter**, states what it can carry, and the node compares
those statements before anything is moved. This document defines:

- the **capability declaration**: the document an adapter publishes;
- a fixed list of **capabilities**, each with a definition of what full support means;
- three **support levels**, `full`, `partial` and `none`, with stated limits and requirements;
- the **comparison rule** that turns one or two declarations into what a given move can carry;
- the **pre-flight report**: what will move, what will not and why, produced before any data is
  written.

It builds on the [governance policy](governance-policy.md), the
[community archive](community-archive.md) and the [privacy modes](privacy-modes.md)
specifications.

The key words MUST, MUST NOT, SHOULD, SHOULD NOT and MAY are to be read as in
[RFC 2119](https://www.rfc-editor.org/rfc/rfc2119) and
[RFC 8174](https://www.rfc-editor.org/rfc/rfc8174).

## 2. Terms

| Term | Meaning |
|---|---|
| **Adapter** | the part of a node that carries a community, or part of one, into or out of the node through one interface |
| **Interface** | what the adapter speaks or reads: a file format or a protocol, named by an identifier (§4.2) |
| **Counterpart** | whatever is on the other side of the interface: another node, another kind of server, or a file |
| **Capability** | one kind of thing that can be carried (§5) |
| **Direction** | `in`: into this node; `out`: out of this node |
| **Declaration** | the JSON document defined in §4 |
| **Move** | any operation that carries a community or part of one through an adapter: a move to another node, an import, an export |
| **Pre-flight report** | the JSON document defined in §8 |

Community, member, right, policy, governance log and node are used as in the governance policy
specification. Archive, member parcel, transfer class, content item and audience are used as in
the community archive specification. Mode, community actor and follower are used as in the
privacy modes specification.

## 3. Principles

**C1. Declared, not assumed.** A node MUST NOT attempt to carry anything through an adapter that
the adapter's declaration does not cover.

**C2. Never more than is true.** A declaration states `full` only where §5 is met in every case
the adapter accepts. Where the outcome depends on a server the node does not control, the level
is at most `partial`.

**C3. A limit is said before, not after.** Whatever will not move is reported before any data is
written and before anything that cannot be undone is sent (§8).

**C4. Less is acceptable, wider is not.** A partial move may leave things behind. It MUST NOT
give anyone access they did not have at the source: an adapter that cannot keep an item's
audience does not carry the item.

**C5. Portability does not depend on federation.** The capabilities that carry a community's
structure, rules, memberships and content (§5.1) are available with federation switched off.

**C6. A declaration describes software.** It contains nothing about a community or a person.

## 4. The capability declaration

A declaration is a JSON object that validates against the schema and satisfies the rules of this
document that a schema cannot express (listed in §11).

| Member | Required | Content |
|---|---|---|
| `spec` | yes | the string `occ.capability-declaration` |
| `version` | yes | the version of this document the declaration follows: `0.1` |
| `adapter` | yes | which adapter this is (§4.1) |
| `counterpart` | yes | what it speaks to or reads (§4.2) |
| `capabilities` | yes | an object: capability name to capability entry (§4.3) |

A declaration belongs to one version of one adapter and does not change while that version
runs. An adapter that speaks two interfaces publishes two declarations.

### 4.1 `adapter`

| Member | Required | Content |
|---|---|---|
| `id` | yes | a name for the adapter: lowercase letters, digits and underscores, in segments separated by dots |
| `version` | yes | the adapter's own version |
| `kind` | yes | `portability`: it reads or writes files; `federation`: it exchanges messages with other servers |

### 4.2 `counterpart`

| Member | Required | Content |
|---|---|---|
| `interface` | yes | the identifier of the format or protocol |
| `versions` | no | the versions of that interface the adapter accepts |
| `system` | no | the kind of software on the other side, when the declaration holds only for that software |

Interface identifiers defined here:

| Identifier | Meaning |
|---|---|
| `occ.community-archive` | the [community archive](community-archive.md); `versions` MUST be given |
| `activitypub` | W3C ActivityPub, server to server |

Any other identifier is chosen by the adapter's author and SHOULD name a published format.

### 4.3 Capability entries

Each member of `capabilities` is named after a capability and holds:

| Member | Required | Content |
|---|---|---|
| `in` | no | support for carrying it into this node (§6) |
| `out` | no | support for carrying it out of this node (§6) |

A capability that is not named, or a direction that is not given, has the level `none`. An entry
MUST give at least one direction.

### 4.4 Identity of a declaration

The **digest** of a declaration is the SHA-256 hash, in lowercase hexadecimal, of its canonical
form under the JSON Canonicalization Scheme ([RFC 8785](https://www.rfc-editor.org/rfc/rfc8785)).
A pre-flight report refers to declarations by digest.

## 5. Capabilities

The names below are fixed. The namespaces `community`, `governance`, `membership`, `member`,
`content`, `identity` and `graph` are reserved for this specification.

### 5.1 Carrying a community

| Capability | What is carried | `full` means |
|---|---|---|
| `community.structure` | the community's identity and settings | every `structural` field of `community.json` arrives unchanged, the identifier included |
| `governance.policy` | the policy in force | the policy arrives with the same digest; rights the destination does not know are kept |
| `governance.log` | the governance log | every entry arrives, the chain verifies and its head equals the one the source stated |
| `membership.records` | memberships by reference | every membership arrives with its reference and state, and the roles derived from the log are the same on both sides |
| `content.items` | content items | every item arrives with its identifier, author, audience and `log_seq` unchanged |
| `content.media` | media files | every file an item refers to arrives with the same digest |
| `member.parcel` | what a member releases: their identity and their own content | a released parcel binds the member to their membership and makes their items readable by the recorded audience, and by nobody else |

An adapter whose interface is `occ.community-archive`:

- MUST declare `governance.policy` and `governance.log` at the level `full` in every direction
  in which it declares `community.structure`. A community is not carried without its rules and
  the record of how they came about;
- MUST NOT state any requirement of §6.2 other than `member_release`, for any capability in this
  table (C5).

### 5.2 Carrying a federated identity

| Capability | What is carried | Best case |
|---|---|---|
| `identity.actor_move` | the community actor's identity: other servers learn the actor's new address and can verify it from both ends | the old actor announces the new one, the new one names the old one, and servers that honour the announcement treat them as the same |
| `graph.followers` | the followers of the community actor | each follower's server follows the new actor in place of the old one |

Both depend on what other servers do. An adapter MUST NOT declare either at the level `full`
(C2); the level is `partial` with the limit `remote_dependent`, or `none`.

Followers are never written to an archive (privacy modes specification, §5.4), so
`graph.followers` MUST NOT be declared by an adapter whose interface is `occ.community-archive`.

### 5.3 Extension capabilities

An extension that stores data about a community names its own capabilities in a namespace of its
own, for example `calendar.events`, one per kind of record. An extension MUST NOT define a
capability in a reserved namespace. Its declaration entry has the same form, and what `full`
means is for the extension to define.

An implementation that reads a declaration naming a capability it does not know MUST treat that
capability as `none` when comparing (§7), and MUST NOT fail because of it.

## 6. Support

A direction of a capability entry holds:

| Member | Required | Content |
|---|---|---|
| `level` | yes | `full`, `partial` or `none` |
| `limits` | with `partial`; absent otherwise | what is not carried, or not guaranteed (§6.1); at least one |
| `requires` | no; absent with `none` | what must hold for the level to apply (§6.2) |

The levels are ordered: `none`, then `partial`, then `full`.

- `full`: what §5 defines, in every case the adapter accepts, once the requirements are met.
- `partial`: something is carried and something is not. The limits say what.
- `none`: nothing is carried. Stating `none` is the same as leaving the direction out.

### 6.1 Limits

A limit has a `code` and may have a `detail`: a sentence of at most 280 characters, written for
the person who decides whether to go ahead.

| Code | Meaning | `detail` |
|---|---|---|
| `remote_dependent` | the outcome depends on what another server does, and the adapter cannot find out for certain | optional |
| `subset` | only part of what the capability covers is carried | required: which part |
| `local_only` | what arrives is kept and shown inside the community, and is not published again under its original identity | optional |
| `manual_step` | a person has to do something outside the adapter | required: what |
| `irreversible` | once started it cannot be taken back | optional |

An extension MAY define a limit code in its own namespace, for example `calendar.no_recurrence`;
such a limit MUST have a `detail`. A reader that does not know a limit code shows the code and
the detail and treats the level as `partial`.

### 6.2 Requirements

A requirement is one of these codes:

| Code | Holds when |
|---|---|
| `federation_enabled` | the node supports a mode other than `private` |
| `mode_discoverable` | the community's mode is `discoverable` or `federated` |
| `mode_federated` | the community's mode is `federated` |
| `counterpart_reachable` | the other side answers while the move is carried out |
| `member_release` | the member concerned has released their parcel |

A requirement that does not hold at the time of a move makes the level `none` for that move
(§7.3). `member_release` is decided member by member and is the one requirement that may hold
for part of a community.

An adapter of kind `portability` MUST NOT state `federation_enabled`, `mode_discoverable` or
`mode_federated`.

## 7. Comparing declarations

### 7.1 Which declarations apply

A move has a source and a destination, and one or two declarations apply to it:

| Move | Declarations |
|---|---|
| from one node to another | the source adapter's, for the direction `out`, and the destination adapter's, for the direction `in` |
| into a node, from a file or a server that publishes no declaration | the destination adapter's, for the direction `in` |
| out of a node, to a file or a server that publishes no declaration | the source adapter's, for the direction `out` |

Where two declarations apply, their `counterpart.interface` MUST be equal and their
`counterpart.versions` MUST have a version in common. If not, nothing can be carried and the
result of the pre-flight report is `blocked`, with the finding `interface_mismatch`.

Where one declaration applies, it speaks for both sides: the adapter's author knows the
counterpart and MUST have declared what the counterpart cannot do as limits of the adapter.

### 7.2 Declared level

For each capability named in either declaration:

1. the **declared level** is the lower of the levels that apply;
2. the limits are those of every declaration that applies, taken together;
3. the requirements are those of every declaration that applies, taken together.

### 7.3 Effective level

The declared level says what the software can do. The **effective level** says what this move
will do, and is found by checking each requirement against the facts at the time of the move:

- a requirement that does not hold makes the effective level `none`, and is listed as unmet;
- facts MAY lower a level and MUST NOT raise one. An adapter that discovers at the time of a
  move that the counterpart can do more than was declared carries no more than was declared;
- an adapter that discovers the counterpart can do less (an older version, a feature switched
  off) lowers the level and adds the limit that describes it.

### 7.4 Outcome

| Effective level | Outcome |
|---|---|
| `full` | `moves` |
| `partial` | `moves_partly` |
| `none` | `stays` |

A capability with the outcome `stays` is left untouched at the source. Nothing in this
specification deletes anything.

## 8. The pre-flight report

Before a move writes anything at the destination, and before a federation adapter sends anything
that cannot be taken back, the node that carries out the move MUST produce a pre-flight report
and show it to the person who authorises the move. For a community this is a member holding
`portability.export` or `portability.move`; for a member's own export it is that member.

A report is a JSON object that validates against the schema:

| Member | Required | Content |
|---|---|---|
| `spec` | yes | the string `occ.preflight-report` |
| `version` | yes | `0.1` |
| `created_at` | yes | when the report was produced, UTC, RFC 3339 |
| `community` | yes | `id`: the community's identifier |
| `source` | at least one of the two | the source adapter: `adapter` (its `id`), `version`, `declaration` (digest) |
| `destination` | at least one of the two | the destination adapter, in the same form |
| `capabilities` | yes | an object: capability name to result (§8.1) |
| `findings` | yes | what else the person needs to know (§8.2); may be empty |
| `result` | yes | `complete`, `partial` or `blocked` (§8.3) |

### 8.1 Capability results

One result for each capability named in a declaration that applies, and for every capability of
§5.1 whether named or not:

| Member | Required | Content |
|---|---|---|
| `level` | yes | the effective level |
| `outcome` | yes | `moves`, `moves_partly` or `stays` |
| `limits` | with `partial` | as in §6.1 |
| `unmet` | no | the requirements that did not hold |

### 8.2 Findings

A finding has a `code`, a `severity` and, where the table says so, a `subject`.

| Code | Severity | `subject` | Raised when |
|---|---|---|---|
| `interface_mismatch` | `blocks` | none | the two declarations do not share an interface and a version (§7.1) |
| `version_unsupported` | `blocks` | the version | the destination does not implement the version of a document it has to read |
| `rules_incomplete` | `blocks` | the capability | the community's structure would be carried without its policy or its full log (§8.3) |
| `mode_unsupported` | `loss` | the mode | the destination does not support the community's mode, so the community would arrive as `private` (privacy modes specification, §8.2) |
| `extension_missing` | `loss` | the extension's name | the destination lacks an extension that has data in the archive; the data is kept and shown to nobody (community archive specification, §11) |
| `right_unknown` | `loss` | the right | the policy names a right the destination does not know; it is kept and permits nothing |
| `members_pending` | `notice` | none | some members have not released their parcels; their items do not arrive until they do |
| `irreversible_step` | `notice` | the capability | carrying this capability sends something that cannot be taken back |

The severities:

- `blocks`: the move MUST NOT be carried out;
- `loss`: something the community has now will be missing, hidden or inactive afterwards;
- `notice`: nothing is lost, and the person should know.

An extension MAY define finding codes in its own namespace, with the severity `loss` or
`notice`. An extension MUST NOT define a finding that blocks.

### 8.3 Result

| Result | When |
|---|---|
| `blocked` | any finding has the severity `blocks` |
| `partial` | not blocked, and any capability has the outcome `moves_partly` or `stays` although the source holds something it covers, or any finding has the severity `loss` |
| `complete` | otherwise |

A move whose purpose is to carry the community itself (an archive with the purpose `move` or
`backup`) is blocked with `rules_incomplete` unless `community.structure`, `governance.policy`,
`governance.log` and `membership.records` all have the effective level `full`. Content may
arrive partly; the rules and the memberships may not.

### 8.4 Going ahead

- A `blocked` move is not carried out.
- A `partial` move is carried out only after the person who authorises it has been shown the
  report and has confirmed it. An implementation MUST NOT offer a way to confirm without the
  report having been shown, and MUST NOT confirm on the person's behalf.
- A `complete` move needs no confirmation beyond the authorisation itself.
- The move that is carried out is the move that was reported. If a requirement stops holding, or
  an adapter or its declaration changes, between the report and the move, a new report is
  produced.
- An adapter MUST NOT carry more than the report said, even if it turns out that it could.

### 8.5 What a report does not contain

A report contains no member reference, no name, no count of members or items, no free text from
the community and nothing from the body of an item. It names software, capabilities, codes,
modes, rights and extensions. It can therefore be kept and shown to every member, and SHOULD be.

## 9. Publishing a declaration

Version 0.1 defines no network endpoint for declarations. A node holds the declaration of each
adapter it runs; in a move between two nodes each side gives its declaration to the other as
part of arranging the move, by whatever means the archive itself is delivered.

A node MUST NOT serve its declarations at a public endpoint in a way that reveals which
communities it holds or which extensions any community uses. A declaration is the same for every
community on the node (C6).

## 10. Versions

`version` follows the specification. While the version starts with `0.`, an implementation
accepts only the versions it implements, exactly. A declaration or a report in a version the
implementation does not implement is not compared: the result is `blocked`, with the finding
`version_unsupported`.

## 11. Rules a schema cannot express

A validator MUST check these in addition to the schema:

1. A declaration with the interface `occ.community-archive` gives `counterpart.versions` (§4.2).
2. In such a declaration, `governance.policy` and `governance.log` are `full` in every direction
   in which `community.structure` is declared above `none`, no capability of §5.1 states a
   requirement other than `member_release`, and `graph.followers` is not declared (§5.1, §5.2).
3. `identity.actor_move` and `graph.followers` are never `full` (§5.2).
4. An adapter of kind `portability` states none of `federation_enabled`, `mode_discoverable`,
   `mode_federated` (§6.2).
5. In a report, each capability's `level`, `limits` and `unmet` follow from the declarations
   named in `source` and `destination` by §7, and `outcome` follows from `level` by §7.4.
6. In a report, `result` follows from the capability results and the findings by §8.3.
7. A finding in an extension's namespace does not have the severity `blocks` (§8.2).

## 12. Relation to other work

- **ActivityPub.** `identity.actor_move` and `graph.followers` describe what the `Move` activity
  and the `alsoKnownAs` property achieve between servers that implement them. This document
  defines no new activity and changes nothing in ActivityPub; it records that the outcome
  depends on the other servers.
- **ActivityStreams 2.0.** An adapter that imports an export made of ActivityStreams objects
  declares `content.items` for the direction `in`, usually as `partial`: such an export carries
  objects and not the audiences this specification requires.
- **Data portability work in the W3C Social Web Community Group.** That work defines how one
  account's content moves between servers. A declaration is how an adapter built on it says
  which part of a community it covers.
- **Other specifications in this folder.** The community archive defines what the capabilities
  of §5.1 carry and what an importer does. The privacy modes specification defines the modes
  the requirements of §6.2 refer to. The governance policy defines the rights that authorise a
  move.

## 13. Not in version 0.1

- **Declarations for extensions themselves**: what an extension adds to a community (its rights,
  its questions, its records), as opposed to what an adapter can carry. The capability names of
  §5.3 are meant to be shared with that declaration when it is written.
- **A node-level document**: which adapters and which modes a node offers, published for other
  nodes to read.
- **A discovery endpoint** and any exchange of declarations over the network (§9).
- **A completion report**: what a move actually carried, in the same form as the pre-flight
  report, including what other servers did with a `remote_dependent` capability.
- **Recording the report**: a governance log entry that names the digest of the report the
  authorising person confirmed.
- **Quantities**: how many items or members a partial move covers.
- **Partial structure**: carrying a community's rules without its memberships, or the reverse.

## 14. Open questions

1. Should a confirmed pre-flight report be named in the `portability.exported` and
   `portability.imported` log entries, so that members can later see what was known when the
   move was authorised?
2. Is one level per direction enough, or does a capability such as `content.items` need a level
   per kind of item?
3. Should `detail` be free text (as specified), or a fixed set of sub-codes that can be
   translated?
4. Should a `backup` be allowed with `membership.records` below `full`, so that a community can
   keep a copy of its rules and content alone?
5. Should the limit `irreversible` on any capability always raise the finding
   `irreversible_step` (as the examples do), or only when the capability has something to carry?
6. Is "an adapter never carries more than it declared, even when it could" (§7.3) too strict for
   a federation adapter, where the other server's abilities are only known at the time of the
   move?
