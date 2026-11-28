<!--
SPDX-FileCopyrightText: 2026 Open Communities Core contributors
SPDX-License-Identifier: CC-BY-4.0
-->

# 0008 — Participant profiles and grants

- Status: Accepted
- Date: 2026-11-22
- Deciders: Adrian Boros

Nothing in this record is implemented yet.

## Context and problem statement

In many communities one person takes part and another handles things for them: a junior in a
sports club, a resident of a care home, an adult who lets a relative act on their behalf. The
person a record is about, the account that signs in and the person who acts for someone else
are then three different things, and software that merges them cannot express who may do what.

Optional modules such as attendance or dues refer to "the person taking part". The core has to
name that person before any module is designed. There is also a narrower need: someone who may
do one thing, for one participant, for a limited time, and see nothing else.

How does the core represent a person who takes part without necessarily having an account, and
how are permissions to act for that person expressed?

## Decision drivers

- A person can take part without an account, and can get one later without losing history.
- Being related to someone gives no rights; every permission is explicit and can be explained.
- One permission check and one audit trail, not one per module.
- Community-first identity: nothing is shared between communities by default.
- The core holds as little personal data as possible.
- Records about such a person never reach federation.

## Considered options

1. A participant profile in the core, with every permission on it expressed as a grant.
2. A profile created by the core for every member.
3. A representative as its own relation with fixed rights, and narrower permissions added later.
4. Profiles shared across communities.

## Decision outcome

**Option 1.** Three terms are kept apart:

| Term | What it is |
|---|---|
| **Participant profile** | the record of a person taking part in a community. Module records refer to it. It exists with or without an account |
| **Account** | what lets someone sign in. A profile is linked to one account or to none |
| **Grant** | an explicit permission for one action on one participant profile |

A *representative* is not a fourth record. It is a named, open-ended set of grants.

| # | Area | Decision |
|---|---|---|
| D1 | Scope | A profile and its records belong to one community. A person can have a profile in each community; each community sees only its own, also when both are on the same node |
| D2 | Who has a profile | The community's template decides which roles get a participant profile ([ADR 0009](0009-modules-and-templates.md)). The core supplies the mechanism and creates none by default |
| D3 | What the core holds | An identifier, a display name, the community, the grants and the link to an account when there is one. Anything else belongs to a module or to the application |
| D4 | One permission model | Every permission on a profile is a grant. A representative holds a named set of grants with no end date; a narrower helper holds one grant, which can be for one day |
| D5 | Adding a representative | A role named by the policy can add one. An existing representative can propose another person; the role confirms. A family relation alone gives nothing |
| D6 | Linking an account | The role issues a single-use invitation bound to the profile, and one current representative confirms before the link takes effect. Where the profile has no representative, the role's step is enough. The identifier and the records stay |
| D7 | After linking | The participant acts for themselves. Existing grants are not removed; they are listed for review, and the participant or the role can withdraw each one |
| D8 | Visibility | Records about a participant are visible to holders of a grant that covers them and to the roles a policy names, never to the whole community by default |
| D9 | Federation | A profile is never a federated actor and never appears in a federation payload, in any privacy mode |
| D10 | Moving | A profile's data moves in the member stage of a move, on a representative's confirmation. Grants move with it and stay bound to the memberships that hold them |

A grant has these fields:

| Field | What it says |
|---|---|
| Action | the one thing permitted, from a list the core and the enabled modules declare. Never a role |
| Participant | one participant profile |
| Community | the community the grant is valid in |
| Holder | the membership that may use it |
| Issuer | the role or representative that gave it |
| Relation | optional: how the holder is related to the participant, as the issuer stated it. It conveys no rights |
| Validity | from when, and until when or open-ended |
| Revocation | who withdrew it and when |
| Consent record | a reference to the consent the grant rests on, where the application records one |

Rules:

1. A grant gives access to its action and nothing else, unless another grant says so.
2. Who may issue which action is set by the community's policy. A representative may issue only
   the actions the policy lets representatives delegate.
3. A grant is never edited. A change is a withdrawal and a new grant, so the history stays.
4. An expired or withdrawn grant cannot be used, and a refusal can be explained from the grant.
5. The check is one function, scoped by community like every other query. A module does not
   write its own.

### Consequences

- Good: modules can refer to a participant without knowing whether an account exists.
- Good: a helper with one narrow permission is the general case, not a special one.
- Good: a grant bound to a membership survives a move to another node, where accounts are
  created again.
- Bad: the core holds the name of a person who may be a minor. That is personal data on every
  node, and its transfer class has to be set in the community archive.
- Bad: a profile with no representative and no account is possible. It is managed by the role
  the policy names, and that state has to be visible to the role.
- The governance policy needs rights to create a profile, confirm a representative, issue a
  linking invitation and delegate an action.

## Pros and cons of the options

**A profile for every member.** Pro: uniform. Con: the core would hold a record most communities
never use.

**A representative as its own relation with fixed rights.** Pro: simple to start. Con: two
permission checks to keep consistent, and the helper with one permission is a special case from
the first day.

**Profiles shared across communities.** Pro: one record per person. Con: contradicts
community-first identity; matching people across communities is a decision for later, if ever.

Within option 1, two variants were not taken: a representative adding another directly (the
community could not refuse an addition it has reason to refuse), and the role linking an account
alone (a representative would be told, not asked, when the person they act for starts acting
alone).

## More information

Open: the first list of actions and who may delegate each, which depends on the first module;
whether a community may block the withdrawal of a profile's last representative while the
participant has no account; whether linking an account needs an age rule, which is for the
application and its legal advice to decide.

Tests that will accompany the implementation: isolation of profiles between communities on one
node; one action per grant; expired and withdrawn grants; a grant on one participant never
covering another; proposal and confirmation of a representative; linking an account without
changing identifier or records; no profile in any federation payload; profiles and grants
arriving only in the member stage of a move.
