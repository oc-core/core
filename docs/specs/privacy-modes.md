<!--
SPDX-FileCopyrightText: 2026 Open Communities Core contributors
SPDX-License-Identifier: CC-BY-4.0
-->

# Privacy modes

- Status: Draft
- Version: 0.1
- Date: 2026-11-22
- Editor: Adrian Boros
- Schema: [`schemas/privacy-setting.schema.json`](schemas/privacy-setting.schema.json)
- Examples: [`examples/`](examples/), one per mode

Nothing in this document is implemented yet. It is published as a draft so that it can be
reviewed before the first implementation, and it will change.

## 1. Purpose

A community on Open Communities Core decides how far it is visible outside its own membership.
It does so by being in exactly one **privacy mode**. This document defines:

- three modes, `private`, `discoverable` and `federated`, and what each permits and forbids;
- the **privacy setting**: the document that records a community's mode and its parameters;
- how the setting is changed, with notice to members when it becomes more open and retraction
  when it becomes stricter;
- what a node does with a mode it does not support;
- how the modes relate to the audiences and transfer classes of the
  [community archive](community-archive.md).

It builds on the [governance policy](governance-policy.md) specification: the setting is changed
with a right in the reserved `privacy` namespace, and every change is a governance log entry.

Federation is a capability a community may switch on. It is never a condition for using a node,
for exporting a community or for moving it.

The key words MUST, MUST NOT, SHOULD, SHOULD NOT and MAY are to be read as in
[RFC 2119](https://www.rfc-editor.org/rfc/rfc2119) and
[RFC 8174](https://www.rfc-editor.org/rfc/rfc8174).

## 2. Terms

| Term | Meaning |
|---|---|
| **Privacy setting** | the JSON document defined in §4; a community has exactly one in force |
| **Mode** | the `mode` of the setting in force: `private`, `discoverable` or `federated` |
| **Federation adapter** | the part of a node that speaks to other servers, here through ActivityPub |
| **Federation payload** | anything the federation adapter sends to, or serves to, another server: an actor document, a discovery answer, an activity, an object, a collection |
| **Public endpoint** | any address on a node that answers without the requester being a signed-in member of the community concerned |
| **Community actor** | the ActivityPub actor that stands for a community towards other servers |
| **Follower** | a remote actor whose `Follow` of a community actor was accepted. A follower is not a member |
| **Public item** | a content item created for publication outside the community (§6) |
| **More open**, **stricter** | the two directions in which a setting can change (§7.2) |

Community, member, right, role, policy, proposal, governance log and node are used as in the
governance policy specification. Member reference, transfer class, content item and audience are
used as in the community archive specification.

## 3. The three modes

| Mode | Community actor | What other servers can learn | What is sent to other servers |
|---|---|---|---|
| `private` | none | nothing, not even that the community exists | nothing |
| `discoverable` | yes | the handle, and the metadata fields the community approved | the actor document, and nothing else |
| `federated` | yes | as `discoverable`, plus the public items | public items, to followers |

`private` is the default. A community is `private` until a governed change says otherwise (§4.4).

The modes are ordered: `private` is the strictest, `federated` the most open. Each mode permits
everything the stricter one permits and nothing that §5.1 forbids.

## 4. The privacy setting

A privacy setting is a JSON object that validates against the schema and satisfies the rules of
this document that a schema cannot express (listed in §12).

| Member | Required | Content |
|---|---|---|
| `spec` | yes | the string `occ.privacy-setting` |
| `version` | yes | the version of this document the setting follows: `0.1` |
| `mode` | yes | `private`, `discoverable` or `federated` |
| `notice_days` | no | length of the notice period for a change that makes the setting more open (§7.3); default 14; MUST be at least 14 |
| `discovery` | in `discoverable` and `federated`; absent in `private` | the public identity (§4.1) |
| `federation` | in `federated`; absent otherwise | what may be published (§4.2) |

### 4.1 `discovery`

| Member | Required | Content |
|---|---|---|
| `handle` | yes | the local name of the community actor: 1 to 64 characters, lowercase letters, digits and underscores, not starting with an underscore |
| `fields` | yes | the metadata fields approved for publication; may be empty |

The fields that can be approved are fixed:

| Field | What is published |
|---|---|
| `name` | the community's name |
| `summary` | a short text written for the public |
| `icon` | one image |
| `link` | one `https` address at which the community can be contacted or read about |

A field that is not listed in `fields` is not published. No other metadata can be approved. In
particular the number of members, the list of members, the roles and their holders, the date the
community was created and the description shown to members are never published (§5.1).

The setting says which fields are public, not what they contain. The values are the community's
own and are changed with the right `community.update`. The `summary` is a text of its own: an
implementation MUST NOT fill it from the description shown to members.

### 4.2 `federation`

| Member | Required | Content |
|---|---|---|
| `kinds` | yes | the kinds of content item that may be created as public items; at least one |

A kind is the `kind` of a content item as the community archive specification uses it. A kind
defined by an extension MUST NOT be listed in version 0.1 (§5.1, P4).

### 4.3 Identity of a setting

The **digest** of a setting is the SHA-256 hash, in lowercase hexadecimal, of its canonical form
under the JSON Canonicalization Scheme ([RFC 8785](https://www.rfc-editor.org/rfc/rfc8785)).
The governance log refers to settings by digest.

### 4.4 One setting in force, and the default

A community has exactly one setting in force at any time. A community whose governance log
contains no `privacy.changed` entry has the **default setting**:

```json
{ "spec": "occ.privacy-setting", "version": "0.1", "mode": "private" }
```

A node MUST NOT create a community in any other setting, and MUST NOT offer a way to configure a
different default. A community becomes `discoverable` or `federated` only by the change defined
in §7.

## 5. What each mode permits

### 5.1 Rules that hold in every mode

A setting cannot weaken these, and neither can a policy.

**P1. Members are not exposed.** No federation payload and no public endpoint contains a member
reference, a member's name or address, the list or the number of members, a role, the holders of
a role, or the fact that a given person is or was a member.

**P2. No member is an actor.** The only actor a community has is the community actor. A member
is never a federated actor in version 0.1, and a public item is attributed to the community
actor alone (§6).

**P3. Participant profiles stay inside.** Where a community keeps records about people who are
not themselves members with an account (for example persons represented by a member), such a
record is never an actor and never appears in a federation payload or at a public endpoint.

**P4. Extension data stays inside.** Data stored by an extension is not readable by the
federation adapter and never appears in a federation payload or at a public endpoint. Version
0.1 defines no way to lift this.

**P5. Governance stays inside.** The policy, the governance log and the privacy setting itself
are never delivered to another server through federation.

**P6. Only what was made public is public.** A content item appears in a federation payload only
if it is a public item (§6) and the mode is `federated`. An item with any other audience never
does, in any mode, and cannot be turned into a public item later.

**P7. A follower is not a member.** Following a community actor gives a remote actor the public
items and nothing else: no membership, no right, no access to anything a member can read.

**P8. Nothing leaks sideways.** A field that may not appear in a federation payload MUST NOT
appear in an error message returned to another server, in a redirect, or in an address. A node's
own public description of itself MUST NOT name or list a community that is not `discoverable` or
`federated`.

**P9. Portability does not depend on the mode.** Exporting a community, moving it and importing
it work in every mode and need no federated identity.

P1 to P6 are checked in the domain model, before anything reaches the federation adapter: the
adapter is given only what it may send. An adapter that filters what it was given does not
satisfy this specification.

### 5.2 Private

| Area | Rule |
|---|---|
| Discovery | The community has no handle. A discovery request (WebFinger or any other) for a name that would have been its handle MUST be answered exactly as a request for a name that does not exist |
| Actors | There is no community actor and no actor document, inbox, outbox or collection |
| Outbound | The federation adapter MUST refuse to send anything on behalf of the community |
| Inbound | Nothing addressed to the community is accepted. The answer MUST NOT differ from the answer for a community that does not exist |
| Member data | P1 to P4; nothing leaves the node except through an export |

A private community is invisible to the federation adapter as a whole: the adapter cannot
enumerate it, read it or be asked to act for it.

### 5.3 Discoverable

| Area | Rule |
|---|---|
| Discovery | The handle resolves to the community actor |
| Actors | The actor document contains the technical members ActivityPub requires, the handle, and the fields listed in `discovery.fields`. It contains nothing else about the community |
| Outbound | Nothing except the actor document, and the retraction of §7.4. The outbox exists, because ActivityPub requires it, and is empty |
| Inbound | Nothing is accepted. A `Follow` is answered with `Reject`. Every other activity is discarded and not stored |
| Member data | P1 to P4. There are no followers and no followers collection |

A discoverable community can be found and has nothing to read. How a person asks to join it is a
matter between that person and the community (for example through the `link` field), not of
federation.

### 5.4 Federated

| Area | Rule |
|---|---|
| Discovery | As `discoverable` |
| Actors | As `discoverable` |
| Outbound | Public items and their later edits and deletions (`Create`, `Update`, `Delete`), answers to follow requests (`Accept`, `Reject`), and the retraction of §7.4. Nothing else |
| Inbound | `Follow`, `Undo` of a `Follow`, and `Delete` of a remote actor, each with a valid signature of the actor it claims to come from. Every other activity, including replies, mentions, likes and shares, is discarded and not stored |
| Member data | P1 to P4 |

Followers:

- A `Follow` with a valid signature is accepted. A `Delete` of a remote actor removes that actor
  from the followers.
- The identifiers of followers are data about people outside the community. They are kept only
  to deliver public items, are not published (the followers collection MUST NOT list its items
  to an unauthenticated requester) and are never part of a community archive.

**What is sent cannot be reliably taken back.** Another server may keep, show or forward a
public item after the community deletes it, changes mode or closes. An implementation MUST say
so to a member before they create a public item, and to whoever proposes a change to
`federated`.

## 6. Public items

In `federated` mode a content item is a **public item** when all of these hold:

1. it was created as public: the choice is made when the item is created, by the member who
   creates it;
2. that member holds the right `privacy.publish`;
3. its `kind` is listed in `federation.kinds` of the setting in force;
4. a `privacy.published` entry naming the item is recorded in the governance log as part of
   creating it (§7.6).

Rules:

- An item that was not created as public MUST NOT become a public item. To publish what an
  earlier item says, a member creates a new public item.
- A public item is readable by every member, and is recorded in a community archive with the
  audience scope `members` (§9.1).
- A federation payload for a public item contains its body and its media, a public address for
  it, its time of publication, and the community actor as the party it is attributed to. It MUST
  NOT contain the author's member reference or name, or the item's `log_seq`.
- The author, or a member holding `privacy.publish`, MAY retract a public item. A `Delete` is
  sent, its public address stops answering with the item, and `privacy.retracted` is recorded.
  The item remains an item of the community, readable by its members, unless it is also deleted
  there.

The right `privacy.publish` is defined by this specification, in the reserved `privacy`
namespace:

| Right | Permits |
|---|---|
| `privacy.publish` | creating public items and retracting them, in `federated` mode |

It permits nothing in the other two modes. A policy MAY give it an approval rule.

## 7. Changing the setting

### 7.1 Who may change it

The setting is replaced only by the action `privacy.change`, the right defined in the governance
policy specification, §4.1. The approval rule the policy attaches to `privacy.change`, if any,
applies as defined there (§6). A node operator holds no such right by operating the node.

A change names the complete new setting. The implementation MUST refuse a new setting that is
not valid, or whose mode the node does not support (§8.1).

### 7.2 More open or stricter

A change is **more open** when the new setting, compared with the setting in force, does any of
the following:

- moves the mode towards `federated`;
- adds a field to `discovery.fields`;
- adds a kind to `federation.kinds`;
- has a shorter `notice_days`.

A change that does none of these is **stricter**. A change that does one of them and also
removes something is more open as a whole; it SHOULD be made as two changes, so that the
stricter part takes effect at once.

Replacing `discovery.handle` is more open, because a new public name appears, and the old handle
is retracted as in §7.4.

### 7.3 A more open change: notice

A more open change does not take effect when it is decided. It takes effect after a notice
period.

1. **Decision.** A member holding `privacy.change` makes the change, and the approval rule is
   satisfied.
2. **Scheduling.** `privacy.change_scheduled` is recorded with the complete new setting.
3. **Notice.** Every member is told: the mode in force and the new mode, what exactly becomes
   visible outside the community, when the change takes effect, that what is published cannot be
   reliably taken back, and that they may leave before then. `privacy.notice_issued` is recorded
   when the notice has been issued to all members.
4. **Effect.** When the notice period has passed, the new setting comes into force and
   `privacy.changed` is recorded.

The notice period is the `notice_days` of the setting in force, not of the new one. It is at
least 14 days and starts when the notice has been issued to all members. A person who becomes a
member during the notice period is told on joining.

During the notice period:

- the setting in force is unchanged, and nothing the new setting would permit is done;
- a member MAY leave the community and export their own data;
- a member holding `privacy.change` MAY withdraw the change; `privacy.change_withdrawn` is
  recorded and the setting in force stays in force;
- no second change can be scheduled. A stricter change (§7.4) may still be made; it takes effect
  at once and withdraws the scheduled one.

Nothing that existed before a more open change takes effect becomes visible through it, except
the approved metadata fields. Content created before the community became `federated` was not
created as public and is covered by P6.

### 7.4 A stricter change: stop and retract

A stricter change takes effect as soon as it is decided, without a notice period.
`privacy.changed` is recorded, and from that moment the implementation MUST:

| Change | Stop | Retract |
|---|---|---|
| a kind is removed from `federation.kinds` | creating public items of that kind | nothing; items already published stay published until retracted one by one (§6) |
| a field is removed from `discovery.fields` | serving the field | send an `Update` of the actor without it |
| `federated` to `discoverable` | sending public items; accepting followers | send a `Delete` for every public item; stop serving them at their public addresses; remove all followers |
| `federated` or `discoverable` to `private` | everything | as above, then send a `Delete` for the community actor; stop answering discovery requests and requests for the actor, as in §5.2 |

Retraction is a request to other servers, which they may ignore. The implementation SHOULD
attempt delivery of each retraction for a reasonable time and MUST NOT report to the community
that remote copies are gone.

After a community actor has been deleted, its identifier SHOULD NOT be used again, by the same
community or another one: servers that received the deletion commonly refuse the identifier from
then on. A community that later becomes `discoverable` again takes a different handle.

An item that was a public item before a stricter change remains an item of the community with
its audience of all members. It does not become public again if the community later returns to
`federated`.

### 7.5 During a transfer of control

A transfer of control, as the governance policy specification defines it, does not change the
privacy setting. While the community is in transitional mode `privacy.change` is suspended, so:

- a change that is scheduled and has not taken effect when the transfer is accepted is
  withdrawn, with `privacy.change_withdrawn`;
- an incoming controller who wants a more open setting makes the change after the transfer has
  taken effect, with the full notice of §7.3.

`privacy.publish` is not suspended: a federated community keeps publishing during a transition.

### 7.6 Governance log entries

This specification adds these entry types in the reserved `privacy` namespace:

| Type | Recorded when | `data` |
|---|---|---|
| `privacy.change_scheduled` | a more open change has been decided | `from`: digest of the setting in force; `setting`: the complete new setting; `effective_at`: the earliest time it can take effect |
| `privacy.notice_issued` | the notice has been issued to all members | `setting`: digest of the new setting; `effective_at`: when it takes effect |
| `privacy.change_withdrawn` | a scheduled change is given up | `setting`: digest of the new setting; `reason`: `withdrawn`, `superseded` or `transfer_of_control` |
| `privacy.changed` | a setting comes into force | `from`: digest of the previous setting; `setting`: the complete new setting; `reason`: `decision` or `unsupported_mode` (§8.2) |
| `privacy.published` | a public item is created | `item`: the identifier of the item |
| `privacy.retracted` | one public item is retracted | `item`: the identifier of the item |

The entries carry no free text and no personal data; a handle and a kind are identifiers. The
retraction that follows a stricter change is not recorded item by item: the `privacy.changed`
entry stands for it.

The setting in force at any time can be derived from the log alone: it is the `setting` of the
last `privacy.changed` entry, or the default setting when there is none.

## 8. Nodes

### 8.1 Supported modes

A node MUST support `private`. It MAY support `discoverable` and `federated`, and a node that
supports `federated` MUST support `discoverable`. A node on which federation is switched off
supports `private` only, and is a complete node.

- A node MUST refuse a `privacy.change` to a mode it does not support, before any proposal is
  created.
- A node MUST NOT put a community into a more open setting than the one in force by any means
  other than §7. Switching federation on for a node changes no community's setting.
- A node operator who switches off a mode that communities on the node are in MUST treat each of
  them as §7.4 requires for a change to the strictest mode the node still supports, and record
  `privacy.changed` with the reason `unsupported_mode`.

### 8.2 Arriving by archive

The community archive records the mode in `community.json` and the setting in the governance
log. An importer:

1. derives the setting in force from the log and checks that its mode equals `privacy_mode`;
2. if the node supports that mode, keeps the setting;
3. if it does not, says so before creating anything, so that whoever runs the import can stop;
   if the import goes ahead, the community arrives as `private`: the importer records
   `privacy.changed` with the default setting and the reason `unsupported_mode`, after
   `portability.imported`.

An entry made for this reason has no `actor`.

A community never arrives in a more open setting than it left with. An importer MUST NOT create
a community actor for a community that arrives as `private`, and MUST NOT start sending or
serving anything for a `discoverable` or `federated` community until its import is complete.

### 8.3 Moving a federated identity

An actor's identifier is bound to the node that serves it. When a `discoverable` or `federated`
community moves to another node, the destination serves a new community actor, and the source
MAY announce it with ActivityPub `Move`, which carries followers on servers that honour it. The
followers themselves are not in the archive (§5.4). The actor's private key is never in an
archive (community archive specification, §5, rule 4); the destination creates its own.

## 9. Relation to the community archive

### 9.1 Audience scopes

The audience scopes of the community archive, `members`, `roles` and `listed`, say which members
may read an item. None of them reaches outside the community, and this specification adds none.

| Audience scope of an item | May be a public item |
|---|---|
| `members` | yes, when created as one (§6) |
| `roles` | never |
| `listed` | never |

Publication is not an audience. It is a separate fact about an item, recorded by its
`privacy.published` entry. Because an item's `log_seq` is the number of the last governance log
entry at the time it was created, the `log_seq` of a public item is the `seq` of its
`privacy.published` entry. An importer can therefore tell which items were public from the
archive alone, and MUST NOT treat any other item as public.

### 9.2 Transfer classes

The transfer classes say what may travel in which archive. They also bound what the federation
adapter may be given:

| Transfer class | In a federation payload |
|---|---|
| `structural` | only the handle and the values of the fields listed in `discovery.fields` |
| `personal` | never |
| `content` | only the body and the media of public items |
| `derived` | never; in particular no count of members |

Anything an extension stores is outside a federation payload whatever its class (P4).

### 9.3 Where the setting is in an archive

Version 0.1 of the community archive has no file for the privacy setting. The setting travels in
the governance log, and `community.json` repeats its mode in `privacy_mode`, which MUST equal
the mode of the setting in force. The values of the approved metadata fields other than the
community's name are not yet carried by an archive (§13).

## 10. Versions

`version` follows the specification. While the version starts with `0.`, an implementation
accepts only the versions it implements, exactly. An implementation that reads a setting in a
version it does not implement MUST treat the community as `private` until a valid setting is in
force, and MUST NOT guess.

## 11. Relation to other work

- **ActivityPub and ActivityStreams.** A community actor is an ActivityPub actor and a public
  item is delivered as an ActivityStreams object, so that existing servers can follow a
  community and read what it publishes. This document restricts which activities a node sends
  and accepts for a community; within that it changes nothing in either specification. Which
  actor type a community uses, and which object types its public items map to, are not fixed in
  version 0.1 (§13).
- **WebFinger** ([RFC 7033](https://www.rfc-editor.org/rfc/rfc7033)). The handle of §4.1 is
  what a WebFinger request resolves. A private community has no WebFinger answer.
- **Data portability (W3C Social Web Community Group).** That work, and ActivityPub `Move`,
  concern a federated identity that changes server. Here they apply to the community actor only
  (§8.3). Moving the community itself is the subject of the community archive and works with no
  federated identity at all (P9).
- **Other specifications in this folder.** The governance policy defines the right
  `privacy.change` and the log this document writes to. The community archive carries the mode
  and the log.

## 12. Rules a schema cannot express

A validator MUST check these in addition to the schema:

1. No kind in `federation.kinds` is defined by an extension (§4.2).
2. The handle is not in use by another community on the node, and is not the identifier of an
   actor that was deleted (§7.4).
3. A `privacy.change_scheduled` entry is followed, for the same setting digest, by at most one
   of `privacy.changed` or `privacy.change_withdrawn`, and no other change is scheduled before
   that entry.
4. A `privacy.changed` entry that makes the setting more open (§7.2) is preceded by a
   `privacy.change_scheduled` and a `privacy.notice_issued` entry for the same digest, and its
   time is not earlier than the notice entry's time plus the `notice_days` of the setting it
   replaces.
5. The `from` of a `privacy.changed` or `privacy.change_scheduled` entry is the digest of the
   setting in force before it.
6. A `privacy.published` entry is made while the setting in force is `federated`, by a member
   holding `privacy.publish`, for an item whose kind is in `federation.kinds`, whose audience
   scope is `members` and whose `log_seq` is the entry's `seq`.
7. `privacy_mode` in an archive's `community.json` equals the mode of the setting derived from
   its governance log.

## 13. Not in version 0.1

- **Members as actors.** A member with a federated identity of their own, and items attributed
  to their author.
- **Inbound content.** Replies, mentions, likes and shares from other servers, and any way of
  showing them to members.
- **Publishing extension data.** A way for a policy to let an extension's data, for example a
  calendar of public events, reach the federation adapter (P4).
- **Control over followers**: approving follow requests by hand, blocking an actor or a server,
  restricting fetches to signed requests.
- **The mapping to ActivityStreams**: the actor type of a community and the object types of
  public items.
- **Carrying public metadata in an archive**: the values of `summary`, `icon` and `link`.
- **Discovery other than by handle**: directories, search, listings of communities on a node.
- **Per-member choices**: a member who agrees to the community being federated but not to a
  particular field or kind.

## 14. Open questions

1. Is 14 days the right floor for a more open change in every case, including a change that only
   adds one metadata field or one kind?
2. Should the values of the approved fields be part of the setting, so that the exact public
   text is approved and logged, at the cost of free text in the governance log?
3. Should a follow request be accepted automatically (as specified) or wait for a member holding
   `privacy.publish`?
4. May a node's public description of itself count private communities in a total, or does a
   total already say too much on a small node?
5. Should retracting a single public item require the right `privacy.publish` when the person
   retracting is its author, or is authorship enough (as specified)?
6. When a node stops supporting a mode (§8.1), should members get notice even though the change
   is stricter?
7. Should `privacy.publish` and the entry types of §7.6 be listed in the governance policy
   specification's own tables, as `privacy.change` is?
