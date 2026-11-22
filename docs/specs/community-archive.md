<!--
SPDX-FileCopyrightText: 2026 Open Communities Core contributors
SPDX-License-Identifier: CC-BY-4.0
-->

# Community archive

- Status: Draft
- Version: 0.1
- Date: 2026-11-22
- Editor: Adrian Boros
- Schemas: [`schemas/community-archive/`](schemas/community-archive/)
- Sample: [`examples/community-archive/`](examples/community-archive/), shown unpacked

Nothing in this document is implemented yet. It is published as a draft so that it can be
reviewed before the first implementation, and it will change.

## 1. Purpose

A community archive is the form in which a community leaves one node and arrives on another, or
is kept as a backup, with its rules and its history of decisions intact. This document defines:

- two kinds of archive: the **structure archive** and the **member parcel**;
- the container, the files in it and the fields of each file;
- a transfer class for every field, so that an exporter can leave out what it may not send;
- how integrity is checked;
- what an importer must do, and must refuse to do.

It builds on the [governance policy](governance-policy.md) specification: an archive carries the
policy in force and the governance log, and an export is itself a governed action.

The key words MUST, MUST NOT, SHOULD, SHOULD NOT and MAY are to be read as in
[RFC 2119](https://www.rfc-editor.org/rfc/rfc2119) and
[RFC 8174](https://www.rfc-editor.org/rfc/rfc8174).

## 2. Why two kinds of archive

The people who may decide that a community moves are not entitled to hand every member's
personal data to another operator. Each member decides about their own. So a move has two
stages, and the format has two kinds of archive to match:

| Kind | Carries | Released by |
|---|---|---|
| **Structure archive** | the community, its policy, its governance log, its memberships by reference, and a list of its content | the right `portability.export` or `portability.move` |
| **Member parcel** | one member's identity, and the content that member wrote | that member, or a documented basis (§9) |

A structure archive contains no name, address or other direct identifier of a person. It refers
to members only by **member reference** (§4). The table that says which person a reference
stands for is split across the member parcels, one row each.

| Situation | What is produced |
|---|---|
| One member leaves and takes their data | that member's parcel, on their own request |
| The community changes controller on the same node | nothing; see the governance policy specification, §8 |
| The community moves to another node | one structure archive, then one parcel per member as each is released |
| Backup | one structure archive and every parcel, kept by the same controller |

## 3. Container

An archive is one ZIP file ([APPNOTE](https://pkware.cachefly.net/webdocs/casestudies/APPNOTE.TXT))
containing UTF-8 JSON files and, optionally, media files.

- The suggested file name extension is `.occ.zip`.
- Entries MUST be stored or deflated. Encrypted entries MUST NOT be used; protecting an archive
  in transit or at rest is the job of whatever carries it.
- ZIP64 MAY be used.
- An entry path MUST be relative, use `/` as separator, and consist of segments matching
  `[a-z0-9][a-z0-9._-]*`. It MUST NOT contain `..`, start with `/`, or be a symbolic link.
- No two entries have the same path.
- `manifest.json` is at the root.

An importer MUST reject an archive that breaks any of these rules, before reading its content,
and MUST stop decompressing an entry that grows beyond the size its manifest line declares.

## 4. Member references

A **member reference** is a string of 1 to 64 characters from `A-Z a-z 0-9 _ -` that stands for
one member of one community.

- It is assigned by the community's node when the membership starts. It MUST NOT be derived from
  personal data (not a hash of an address, not a user name).
- It is unique within the community and is never given to another member, also after the
  membership ends.
- It stays the same when the community moves.
- The same person in two communities has two unrelated references.

Everything in a structure archive that needs to name a member uses the reference: the governance
log, the policy's recovery rule, the membership list, the authors and audiences of content.

A reference is a pseudonym, not anonymity. As long as the row that maps it to a person exists
anywhere, what the structure archive says about that reference is personal data and is to be
handled as such.

**When a member leaves, or does not release their parcel for a move,** their mapping row is not
carried and, on a node they have left, is deleted. The reference stays. Entries about them in
the governance log remain, as the acts of a former member, and the log stays verifiable.

## 5. Transfer classes

Every field defined in this document has one transfer class:

| Class | What it is | Where it may appear |
|---|---|---|
| `structural` | what makes the community what it is: identity, settings, policy, memberships by reference, the governance log | structure archive |
| `personal` | what identifies or describes a person | member parcel only |
| `content` | what members wrote or uploaded | the author's member parcel; listed, without the body, in the structure archive |
| `derived` | what can be computed again from the rest: counters, indexes, caches | either; an importer MUST NOT rely on it |

Rules:

1. A structure archive MUST NOT contain a field of class `personal`.
2. An exporter MUST leave out any field it is not authorised to send. The manifest states which
   classes the archive contains.
3. Free text is where personal data hides. A field of class `structural` MUST NOT be free text
   written by a member, except the community's own name and description.
4. The following are never in any archive: passwords and their hashes, session and device
   tokens, invitation tokens, private keys, and credentials for payment or any other external
   service.

Rule 4 means an invitation issued on the old node cannot be used on the new one, and a session
does not survive a move. Members sign in again on the destination.

## 6. The manifest

`manifest.json`, schema [`manifest.schema.json`](schemas/community-archive/manifest.schema.json).
All fields are `structural`.

| Field | Required | Content |
|---|---|---|
| `spec` | yes | `occ.community-archive` |
| `version` | yes | `0.1` |
| `kind` | yes | `structure` or `member` |
| `purpose` | yes | `move`, `backup` or `member_export` |
| `community` | yes | `id`: the community's identifier (§7.1) |
| `created_at` | yes | when the archive was produced, UTC, RFC 3339 |
| `exporter` | yes | `software` and `version` of the program that wrote the archive |
| `authorisation` | yes | who allowed the export (§6.1) |
| `classes` | yes | the transfer classes present in this archive |
| `files` | yes | one line per file (§6.2) |
| `log` | structure only | `entries`: number of log entries; `head`: digest of the last one (§8) |
| `member` | member only | `ref`: the member reference this parcel belongs to |
| `structure` | member, when part of a move | `manifest_sha256`: digest of the structure archive's manifest |
| `release` | member only | on what basis the parcel was released (§9) |
| `extensions` | no | the extensions that have data in this archive: `name`, `version` |

### 6.1 Authorisation

| `authorisation.by` | Other fields | Meaning |
|---|---|---|
| `right` | `right`, `log_seq`, optional `destination` | a member holding `portability.export` or `portability.move` allowed it; `log_seq` is the governance log entry that records the export |
| `member` | none | a member exported their own data, which every member may do |

A structure archive MUST have `by` equal to `right`. The log entry it names is in the archive.

### 6.2 Files

Every file in the container except `manifest.json` and `signatures.json` has exactly one line:

| Field | Content |
|---|---|
| `path` | the entry path |
| `sha256` | SHA-256 of the file's bytes, lowercase hexadecimal |
| `bytes` | size in bytes |
| `class` | the highest transfer class of any field in the file, in the order `derived`, `structural`, `content`, `personal` |
| `role` | what the file is: `community`, `policy`, `governance-log`, `memberships`, `content-manifest`, `member`, `content-item`, `media`, `extension` |

An importer MUST reject an archive in which a file is missing, is not listed, or has a different
hash or size.

### 6.3 Signatures

An archive MAY contain `signatures.json`: a list of detached signatures over the bytes of
`manifest.json`, each with `algorithm`, `key` and `value`. Version 0.1 defines the place and
nothing more: which keys speak for a community or a node is not yet specified (§14). An importer
MUST NOT treat an archive as authentic because this file is present.

So in version 0.1 an archive proves that it is complete and unaltered since it was written. It
does not prove who wrote it. That has to come from how it was delivered.

## 7. Files of a structure archive

### 7.1 `community.json`

Schema [`community.schema.json`](schemas/community-archive/community.schema.json).

| Field | Class | Content |
|---|---|---|
| `id` | structural | the community's identifier: an opaque string in 0.1, unchanged by a move |
| `name`, `description` | structural | as shown to members |
| `created_at` | structural | when the community was created |
| `created_by` | structural | optional: member reference of the creator |
| `privacy_mode` | structural | `private`, `discoverable` or `federated` |
| `data_controller` | structural | `kind`: `person` or `organisation`; `member`: the reference of the member who is the controller |
| `settings` | structural | community settings, as an object; no free text written by members |
| `member_count` | derived | number of memberships in force |

### 7.2 `policy.json`

The policy in force, exactly as defined by the governance policy specification. Its digest MUST
equal the `policy` field of the last entry of the log.

### 7.3 `governance-log.jsonl`

See §8.

### 7.4 `memberships.json`

Schema [`memberships.schema.json`](schemas/community-archive/memberships.schema.json). A list
with one object per membership, past and present:

| Field | Class | Content |
|---|---|---|
| `ref` | structural | the member reference |
| `kind` | structural | `person` or `organisation` |
| `state` | structural | `active` or `ended` |
| `joined_at`, `ended_at` | structural | dates, to the day |
| `label` | structural | only for `organisation`: its name |

Who holds which role is not in this file. It is derived from the governance log, which is the
only authority on it. Pending invitations and requests to join are not exported.

### 7.5 `content/manifest.json`

Schema
[`content-manifest.schema.json`](schemas/community-archive/content-manifest.schema.json). One
line per content item of the community, without its body:

| Field | Class | Content |
|---|---|---|
| `id` | structural | identifier of the item, unique in the community, usable as a path segment (§3) |
| `kind` | structural | the item's type, a string defined by whoever defines the content |
| `author` | structural | member reference |
| `created_at` | structural | time of creation |
| `log_seq` | structural | the number of the last governance log entry at the time of creation |
| `audience` | structural | who may read it (below) |
| `sha256` | structural | digest of the item file |

`audience.scope` is `members` (every member), `roles` (holders of the roles in `roles`) or
`listed` (the references in `members`). An audience is recorded as it was when the item was
created. Together with `log_seq`, this is what lets a node decide who could read an item before
a transfer of control, as the governance policy specification requires (G3).

The body of an item travels in its author's parcel (§10). The structure archive never contains
one.

## 8. The governance log in an archive

`governance-log.jsonl` has one JSON object per line, in order of `seq`, schema
[`log-entry.schema.json`](schemas/community-archive/log-entry.schema.json). The fields are
those of the governance policy specification, §10, plus one:

| Field | Content |
|---|---|
| `prev` | the digest of the previous entry; for the first entry, 64 zeros |

The **digest of an entry** is the SHA-256 of its canonical form under
[RFC 8785](https://www.rfc-editor.org/rfc/rfc8785), `prev` included. The manifest's `log.head`
is the digest of the last entry.

Rules:

1. `actor`, and every member named in `data`, is a member reference.
2. An entry MUST NOT contain personal data or free text. A reason or comment given with a
   decision is content, not part of the log.
3. An entry is never rewritten to remove a former member. That is what references are for (§4).
4. An importer MUST check that `seq` starts at 1 without gaps, that every `prev` matches, that
   the head matches the manifest, and that replaying the log yields the policy in `policy.json`.
5. An importer continues the same log: its first own entry has the next `seq` and the archive's
   head as `prev`.

This specification adds two entry types in the reserved `portability` namespace:

| Type | Recorded when | `data` |
|---|---|---|
| `portability.exported` | a structure archive is about to be written; it is therefore the last entry in that archive | `purpose`, optional `destination` |
| `portability.imported` | a node has accepted a structure archive | `manifest_sha256` of the archive |

## 9. Member parcels

A member parcel has `kind` equal to `member` and contains:

| Path | Content |
|---|---|
| `member.json` | the mapping row: who the reference stands for |
| `content/items/<id>.json` | the items this member wrote |
| `media/<sha256>` | media files those items use, named by their digest |
| `extensions/<name>/…` | what extensions hold about this member (§11) |

### 9.1 `member.json`

Schema [`member.schema.json`](schemas/community-archive/member.schema.json).

| Field | Class | Content |
|---|---|---|
| `ref` | structural | the member reference |
| `display_name` | personal | the name shown in the community |
| `contact` | personal | optional: one address at which the destination may invite the member to sign in |
| `profile` | personal | optional: further profile fields, as an object |

### 9.2 Release

| `release.basis` | Meaning |
|---|---|
| `member_request` | the member asked for their own data |
| `member_confirmation` | the member confirmed that their parcel may go to the named destination |
| `same_controller` | the archive stays with the same data controller, as in a backup |
| `documented_basis` | another legal basis, recorded by the controller outside the archive; `note` says where |

`release.at` is the time of the request or confirmation. An exporter MUST NOT write a parcel for
a move without one of these, and MUST NOT write a parcel for a member who declined.

### 9.3 Content items

Schema [`content-item.schema.json`](schemas/community-archive/content-item.schema.json). An item
file repeats the fields of its line in the content manifest, except `sha256`, and adds:

| Field | Class | Content |
|---|---|---|
| `body` | content | the item itself, as an object. It MAY be an ActivityStreams 2.0 object |
| `media` | content | digests of the media files it uses |

A parcel contains only items whose `author` is the parcel's member. What others wrote in the
same conversation is in their parcels.

## 10. What an importer does

**A structure archive.** The importer:

1. checks the container (§3), the manifest, every file's hash and size (§6.2), each file against
   its schema, and the log (§8);
2. checks that the policy is valid under the governance policy specification;
3. refuses if a community with the same identifier is already active on the node;
4. creates the community with the same identifier, the policy and the log, and one membership
   per line of `memberships.json`. A membership in state `active` whose parcel has not arrived
   is **awaiting its member**: it holds its roles according to the log, and nobody can act
   through it;
5. records `portability.imported`.

An import is all or nothing. If any check fails, nothing is created and the importer reports
which check failed.

**A member parcel.** The importer:

1. checks it as above, and that `structure.manifest_sha256` is the archive it imported;
2. checks that the reference exists, is awaiting its member, and that every item is listed in
   the content manifest with the same digest and the parcel's member as author;
3. invites the person to sign in, and binds the membership to their account when they do;
4. makes the items readable by the audience recorded for each, and by nobody else.

**What an importer never does:**

- restore a role, delegation or permission that the log shows as ended;
- give a member access to an item whose recorded audience did not include them;
- treat `derived` data as true without recomputing it;
- accept a parcel for a reference whose membership has ended;
- contact members whose parcels have not been released.

**Items that do not arrive.** When an author does not release their parcel, their items stay
listed in the content manifest and their bodies never arrive. A destination shows such an item
as unavailable, or not at all. It MUST NOT fill the gap from another source.

## 11. Extensions

An extension that stores data about a community puts it under `extensions/<name>/`, in both
kinds of archive, and is named in the manifest's `extensions`. Every such file has a manifest
line with its transfer class, and the rules of §5 apply: nothing `personal` in a structure
archive, and what an extension holds about one member goes in that member's parcel.

A permission an extension granted and later withdrew is exported as withdrawn, or not at all.
It is never exported as in force.

An importer that does not have an extension named in the manifest:

- MUST say so before creating anything, so that whoever runs the import can stop;
- if the import goes ahead, MUST keep the extension's files unchanged, include them unchanged in
  any later export, and show them to nobody.

## 12. Versions

`version` follows the specification. While the version starts with `0.`, an importer accepts
only the versions it implements, exactly. From 1.0 on, an importer accepts any archive with the
same first number and ignores fields it does not know, unless they are in a file it must verify
against a schema.

## 13. Relation to other work

- **ActivityStreams 2.0.** A content item's body may be an ActivityStreams object, and is then
  usable by software that reads them. The rest of the archive (policy, log, memberships,
  audiences) has no ActivityStreams equivalent.
- **ActivityPub `Move`.** `Move` tells other servers that an actor has a new address, and
  carries followers on servers that honour it. It moves no data. A community with a federated
  actor that moves nodes uses `Move` for the actor in addition to an archive for the community;
  neither replaces the other.
- **Data portability work in the W3C Social Web Community Group.** That work concerns one
  account moving its own content between servers, which is close to a member parcel. Where it
  settles on a format for a person's content, the member parcel should be able to carry it. It
  does not cover a community with shared rules and several people's data, which is the subject
  here.

## 14. Not in version 0.1

- **Authenticity.** Which keys sign an archive, and how a community's identifier is bound to
  them (§6.3).
- **The transport**: how an archive gets from one node to another, and how the two nodes agree
  that the source stops accepting writes.
- **Incremental archives**: a second export containing only what changed.
- **The content model**: types of items, conversations, reactions. Only the envelope is defined.
- **Organisation members**: what a parcel for an organisation contains.

## 15. Open questions

1. Should a member be able to release their identity but not their content, or the reverse?
2. Is a day's precision right for `joined_at` and `ended_at`, or does it already say too much
   about a reference?
3. When an author does not release a parcel, should the content manifest keep the item's line
   (as specified) or drop it, at the cost of a list that no longer matches the source?
4. Should the mapping row of a former member be deletable on request while they are still
   referenced as the community's data controller in older log entries?
