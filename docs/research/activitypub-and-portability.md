<!--
SPDX-FileCopyrightText: 2026 Open Communities Core contributors
SPDX-License-Identifier: CC-BY-4.0
-->

# ActivityPub and portability: state of the field

- Status: Desk research, nothing run
- Date: 2026-11-28 (every source was read on this date)
- Editor: Adrian Boros

## 1. Question and method

Before OCC implements federation and community portability, what already exists that it should
reuse, and what is missing that it has to define?

This is desk research. Every statement comes from a primary source read on 28 November 2026:
a specification, a project's documentation, its source code or its issue tracker. Nothing was
installed or run. Where a statement rests on one indirect source or on an inference it says so.
The lab tests that will check these findings are in the
[interoperability test plan](../test-plan.md).

Section 9 lists what was not verified.

## 2. Findings in short

1. **ActivityPub moves messages, not accounts or communities.** The Recommendation defines no
   migration. `Move` exists in the vocabulary only as a general activity.
2. **Account migration on the Fediverse is Mastodon's convention**, later written down by a
   community proposal. It carries followers on servers that honour it, and nothing else.
3. **The W3C community group's portability work covers one person's account.** It leaves groups,
   export formats, signatures and identities that are not bound to a server out of scope or
   unspecified.
4. **No federated community software has a protocol for moving a whole community.** One has an
   operation run by administrators; two can relocate a forum because a forum is an account
   there. None carries roles or a record of decisions, and none asks the members.
5. **Identity that is not bound to one server exists as a draft proposal** with several
   implementations. It is the most relevant prior work for a question the community archive
   specification leaves open.
6. **Mastodon documents its actors as persons.** How it treats a community actor of type `Group`
   is not documented and has to be found out by test.

## 3. ActivityPub

[ActivityPub](https://www.w3.org/TR/activitypub/) is a W3C Recommendation of 23 January 2018.
It defines actors with an inbox and an outbox and how servers deliver activities to each other.
The activities it gives rules for are Create, Update, Delete, Follow, Add, Remove, Like, Block,
Undo, Accept, Reject and Announce. It has no rule for `Move`, and does not define `alsoKnownAs`
or `movedTo`.

The [Activity Vocabulary](https://www.w3.org/TR/activitystreams-vocabulary/) (Recommendation,
23 May 2017) defines `Move` as an actor moving an object from an origin to a target. Using it
for an account is a convention built on top.

What the Recommendation does not give:

- a format for exporting what a server holds;
- a model of groups and membership that implementations share;
- a way to move a community;
- confidentiality: delivering to another server's inbox discloses the content to that server.

It also allows an actor to be of any type. Two servers can represent the same thing with
different actor types, and nothing guarantees that they treat it the same way.

## 4. Mastodon

Sources: [Moving or leaving accounts](https://docs.joinmastodon.org/user/moving/) (page dated
27 November 2025), the [ActivityPub](https://docs.joinmastodon.org/spec/activitypub/) and
[Security](https://docs.joinmastodon.org/spec/security/) pages of its specification (the latter
dated 20 July 2026).

### 4.1 How an account moves

1. The person creates an account on the new server.
2. On the new account they declare the old one as an alias. This sets `alsoKnownAs` and changes
   nothing else; it can be undone.
3. On the old account they start the move, naming the new account and giving the password.
4. The old server sends `Move` to the followers, with the old actor as `actor` and `object` and
   the new actor as `target`.
5. Each follower's server checks that the new account names the old one in `alsoKnownAs`, then
   unfollows the old account and follows the new one, if it supports `Move` at all.

### 4.2 What moves

| Moves | How |
|---|---|
| followers | automatically, on servers that support `Move` |
| accounts followed, blocks, mutes, blocked domains, lists | by hand: exported as CSV from the old account and imported on the new one |
| posts and media | not at all. They can be downloaded as an ActivityStreams archive, and Mastodon does not import one |
| direct messages | not addressed by the documentation |

Other limits the documentation states: the move is irreversible for followers; the old account
is no longer usable afterwards; a further move is refused for 30 days.

### 4.3 What Mastodon accepts

- **Actor types.** The specification page says the type is assumed to be `Person`, and that
  `Application` or `Service` marks a bot. `Group` and `Organization` are not mentioned. A pull
  request adding groups was closed without merging on 4 August 2026, with groups to be looked
  at again in 2027.
- **Objects.** `Note` and `Question` are first-class. `Article`, `Page`, `Image`, `Audio`,
  `Video` and `Event` are converted as well as they can be.
- **Activities on a profile.** Follow, Accept, Reject, Add, Remove, Update, Delete, Undo, Block,
  Flag and Move.
- **Signatures.** Mastodon has long used the draft "HTTP Signatures" scheme and still requires
  it for compatibility with older versions. It asks implementers to also support
  [RFC 9421](https://www.rfc-editor.org/rfc/rfc9421) HTTP Message Signatures: version 4.5.0
  validates them by default, and the unreleased 4.7.0 is documented as signing with them as a
  fallback. For RFC 9421 it requires one signature, the `created` parameter, `@method` and
  `@target-uri` signed, and a signed `Content-Digest`. A draft-scheme request must be signed
  within the last 12 hours.
- **Signed objects.** Linked Data Signatures are in use and not recommended to new
  implementers. Validation of object integrity proofs (section 6) is documented for the
  unreleased 4.7.0.

## 5. The W3C community group's portability work

Sources: [Data Portability in ActivityPub](https://swicg.github.io/activitypub-data-portability/),
a draft for a future report of the Social Web Incubator Community Group, and
[LOLA](https://swicg.github.io/activitypub-data-portability/lola.html), version 0.3, a draft
report of the same group. Neither page shows a date. Neither is a W3C Recommendation.

### 5.1 The report

It describes two ways for a person to keep their account:

- **Domain portability.** The person owns the domain, backs up, replaces the software and
  restores at the same addresses. This needs the person to keep a domain and run or rent a
  server, and no standard backup format exists.
- **Moving the actor.** The Mastodon convention of section 4, which the report describes as
  written down afterwards by a community proposal (section 6).

### 5.2 LOLA

LOLA moves one account between two servers that are both online and both cooperate, at the
person's request. The destination obtains an OAuth 2.0 token from the source, limited to that
account, and with it fetches the person's content, including private posts, and the lists of
accounts followed, blocked and liked. The destination saves copies under new identifiers that
point back to the old ones. Followers are not copied; they are rebuilt by a `Move` afterwards.
The page lists no implementation.

### 5.3 Four questions and what the documents say

| Question | Report | LOLA |
|---|---|---|
| What if the old server is gone, unreachable or unwilling? | the move does not work if the old server is down or blocked; content there is lost | an offline server cannot take part; a server may be unwilling; it recommends that portability be exempt from blocks between servers |
| Can something other than a person move? | not addressed | group membership is named as something a future specification could define; moving it is "not yet specified" |
| How is the link between old and new identity verified? | followers check `alsoKnownAs` on the new account and `movedTo` on the old | by the OAuth token for the copy; by `movedTo` for third parties; signatures are out of scope |
| Is an export format specified? | no standard backup format exists | interoperable export and import formats are out of scope |

LOLA also lists as out of scope identities that are not bound to a server, and moving part of
an account.

## 6. Fediverse Enhancement Proposals

Proposals are published at <https://codeberg.org/fediverse/fep>. A proposal marked FINAL is
finished as a document; that says nothing about how widely it is implemented.

| Proposal | Status | What it defines | Relevance |
|---|---|---|---|
| [FEP-1b12](https://fediverse.codeberg.page/fep/fep/1b12/) Group federation | FINAL, 2023 | a `Group` actor that accepts follows and re-sends each accepted activity to its followers inside an `Announce`; moderators are listed in a collection on the group | the existing convention for a community as an actor. Membership is following. Moderation is optional and, by the proposal's own account, implemented by one project. Moving a group is not addressed |
| [FEP-7628](https://fediverse.codeberg.page/fep/fep/7628/) Move actor | FINAL, 2026 | the Mastodon move, written down. Two actors are linked through `alsoKnownAs`, an identity proof or a profile link. In *push* mode the old actor announces the move and its server must be online. In *pull* mode the new actor announces it, the old server may be gone, and the person needs their own copy of the follower list | the convention OCC reuses for a community actor. It moves followers and, as the proposal says, no other data |
| [FEP-ef61](https://fediverse.codeberg.page/fep/fep/ef61/) Portable objects | DRAFT | identifiers built on a decentralised identifier (a key) instead of a host name; the same actor can be served by several servers, and every object carries a proof | the closest prior work for a community identifier that survives a move. Six implementations are named. The identifier scheme may still change |
| [FEP-8b32](https://fediverse.codeberg.page/fep/fep/8b32/) Object integrity proofs | DRAFT | a signature attached to an object, verifiable without asking the server it came from | lets a forwarded or archived object be checked for authorship. Ten implementations are named |
| [FEP-c390](https://fediverse.codeberg.page/fep/fep/c390/) Identity proofs | DRAFT | a verifiable two-way link between a key and an actor | one of the ways FEP-7628 links two actors |

Other proposals on the index that concern this subject, read by title and status only:
non-public groups (FEP-db0e, draft), groups and permissions (FEP-5219, draft), a roadmap for
actor and object portability (FEP-7952, draft), an export endpoint (FEP-9091, draft), an account
export container (FEP-6fcd, draft), moving a whole server's domain (FEP-a427, draft), and a
`migration` collection (FEP-1580, draft).

None of the proposals read defines how a group moves, what happens to its members, or how its
rules travel.

## 7. How existing software moves a community

| Software | Whole community | One account | Roles and rules carried | Members asked |
|---|---|---|---|---|
| Lemmy | no. A proposal has been open since April 2024 without an implementation | settings, subscriptions and block lists by file; no `Move` | (none) | (none) |
| PieFed | yes, by administrators: a community hosted elsewhere is turned into a local one on the destination | not examined | no. An administrator sets the new owner and checks moderators by hand | no. An announcement post in the old community is the only notice |
| Mbin | nothing found | not implemented; a request is open | (none) | (none) |
| Mastodon | no group feature | `Move`, section 4 | (none) | followers are moved without being asked |
| Hubzilla, (streams), Forte | a forum is a channel, and channels can be cloned between servers and kept in sync. That this covers forums is an inference; the documentation does not say so | yes, clone and move | not documented for forums | no |
| Friendica | a forum is an account, and accounts can be relocated by export file. The project moved one of its own forums this way in 2017; the documentation does not mention forums | yes, marked experimental | not documented | no. Contacts' servers are told the new address |
| Mobilizon | nothing found | a design proposal only | (none) | (none) |
| Discourse with its ActivityPub plugin | no. A change of domain is not supported either | (none) | (none) | (none) |
| NodeBB | no. Its `Move` moves a topic between categories on one server | nothing found | (none) | (none) |
| Bonfire | no. Groups did not yet federate between instances in mid-2026 | yes: `Move`, aliases and an archive | (none) | followers are moved without being asked |

The PieFed operation is the only one built for a community. Read from its source code: any
signed-in user of the destination can request the move by declaring the old community locked
and linking an announcement post; an administrator of the destination then rewrites the local
record with new addresses and a new key pair. No activity is sent to other servers, posts are
not copied beyond what the destination already had, and the old server takes no part.

Three things are absent everywhere:

- **Rules and roles.** Nowhere do a community's roles, or the history of who decided what,
  travel as data that the destination can check.
- **Authorisation by the community.** Where a move exists, whoever controls the account or the
  destination server decides.
- **The members' part.** Members are followers. Their own content stays behind or moves without
  their decision.

## 8. The Drupal ActivityPub module

Sources: the [project page](https://www.drupal.org/project/activitypub), its README and source
on the 1.0.x branch, and its issue tracker.

| Point | State |
|---|---|
| Release | 1.0.0-alpha28 of 7 September 2026, for Drupal 10 and 11; alpha since 2019, marked minimally maintained, not covered by Drupal's security advisory policy, 31 sites reporting use |
| Actors | one `Person` per user and one `Application` for the site. No `Group` actor: a request to let any entity be an actor has been open since 2022 |
| Signatures | the draft scheme with RSA and SHA-256. RFC 9421 was not found in the code |
| Activities | Follow, Accept and Undo of a Follow; Create, Update and Delete of `Note` and `Article`; Like and Announce outbound; an inbound `Move` re-follows the new account |
| Tested with Mastodon, by its own README | follow and accept, notes and articles with an image, replies, direct messages. No versions or dates are given |

The Open Social distribution, which is built on Drupal, states no ActivityPub or federation
support on its site or project page and does not depend on this module. A request for it from
2022 has had no answer. A test against "Open Social" is therefore a test against this module on
a Drupal site.

## 9. What was not verified

- Nothing in this document was run. Behaviour is taken from documentation and, where noted,
  from reading source code.
- How Mastodon treats an actor of type `Group` is not documented. Section 4.3 reports the
  absence, not a behaviour.
- The Mastodon specification page and both W3C pages were read in part through an automated
  summary; the statements taken from them were checked against the quoted text where it was
  available.
- The second half of the LOLA page was read the same way.
- For Hubzilla and Friendica, that a forum can be moved is an inference from "a forum is an
  account" plus, for Friendica, one case from 2017.
- What happens to subscribers on other servers after a PieFed move was not read from the code.
- For Lemmy, the changelog of version 1.0 was not read in full.
- Mobilizon and Mbin: "nothing found" means searches of the documentation and tracker found
  nothing, not that the code was read.
- The Drupal module's handling of inbound signatures was read from one file on the development
  branch.

## 10. Consequences for OCC

| Finding | Consequence | Where it lands |
|---|---|---|
| `Move` carries followers only, and only where honoured | a community's federated identity is carried at best partly, and an adapter never declares it as complete | [adapter capabilities](../specs/capabilities.md) §5.2; test T3 |
| `Move` needs the old server online, unless the pull mode of FEP-7628 is used and someone kept the follower list | followers are never in an archive, so a community whose old node is gone starts with no followers. The archive is what makes the community itself survive that case | [privacy modes](../specs/privacy-modes.md) §5.4, §8.3; [community archive](../specs/community-archive.md) |
| Nothing existing carries rules, roles or a history of decisions | this is defined here: the governance policy, the governance log and their place in the archive | [governance policy](../specs/governance-policy.md); community archive §8 |
| Nothing existing asks the members | member parcels: a member's data moves only when that member releases it | community archive §9 |
| LOLA moves one account between cooperating online servers and leaves groups unspecified | not a basis for moving a community. It is a possible later adapter for a member's own content, and the group gap is worth reporting back to its authors | capabilities §12 |
| FEP-ef61 gives identifiers that are not bound to a host | to be evaluated when the binding of a community's identifier to keys is designed, which version 0.1 leaves open | community archive §14 |
| FEP-1b12 is how communities are actors today, and it equates membership with following | OCC keeps the two apart: a follower is not a member. Whether the community actor is a `Group` in the FEP-1b12 sense is decided after T1 | privacy modes §5.1 (P7); test T1 |
| Mastodon documents actors as persons | T1 is run with more than one actor type before the type is fixed | test T1 |
| Mastodon requires the draft signature scheme and recommends RFC 9421 | the federation adapter supports both | test T9 |
| Mastodon treats `Note` as first-class | public items are sent as `Note` first | test T2 |
| The Drupal module has no `Group` actor and only the draft signature scheme | T6 can test follow and delivery against user actors, and can be expected to say little about community actors | test T6 |

## 11. Sources

All read on 28 November 2026.

- W3C, ActivityPub: <https://www.w3.org/TR/activitypub/>
- W3C, Activity Vocabulary: <https://www.w3.org/TR/activitystreams-vocabulary/>
- Mastodon documentation: <https://docs.joinmastodon.org/user/moving/>,
  <https://docs.joinmastodon.org/spec/activitypub/>, <https://docs.joinmastodon.org/spec/security/>;
  groups pull request: <https://github.com/mastodon/mastodon/pull/19059>
- Social Web Incubator Community Group: <https://swicg.github.io/activitypub-data-portability/>,
  <https://swicg.github.io/activitypub-data-portability/lola.html>
- Fediverse Enhancement Proposals: <https://codeberg.org/fediverse/fep>, rendered at
  <https://fediverse.codeberg.page/fep/>
- Lemmy: <https://github.com/LemmyNet/lemmy/issues/4619>,
  <https://github.com/LemmyNet/lemmy/issues/1985>
- PieFed source: <https://codeberg.org/rimu/pyfedi> (`app/community/routes.py`,
  `app/admin/routes.py`, `app/community/forms.py`)
- Mbin: <https://github.com/MbinOrg/mbin/issues/171>
- Hubzilla: <https://hubzilla.org/help/member/clone>; (streams):
  <https://codeberg.org/streams/streams> (`FEDERATION.md`)
- Friendica: <https://wiki.friendi.ca/docs/move-account>, <https://wiki.friendi.ca/docs/forums>,
  <https://friendi.ca/2017/10/09/helpers-forum-moved-to-the-new-node-as-well/>
- Mobilizon: <https://docs.mobilizon.org/5.%20Interoperability/1.activity_pub/>
- Discourse: <https://meta.discourse.org/t/activitypub-and-changed-domains/408845>
- NodeBB: <https://github.com/NodeBB/NodeBB> (`src/activitypub/inbox.js`)
- Bonfire: <https://docs.bonfirenetworks.org/instance-emigration.html>,
  <https://bonfirenetworks.org/posts/bonfire-for-communities/>
- Drupal ActivityPub module: <https://www.drupal.org/project/activitypub>,
  <https://git.drupalcode.org/project/activitypub>; Open Social:
  <https://www.drupal.org/project/social>, <https://www.drupal.org/project/social/issues/3268544>
