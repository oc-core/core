<!--
SPDX-FileCopyrightText: 2026 Open Communities Core contributors
SPDX-License-Identifier: CC-BY-4.0
-->

# 0009 — Optional modules and community templates

- Status: Accepted
- Date: 2026-11-22
- Deciders: Adrian Boros

Nothing in this record is implemented yet.

## Context and problem statement

Communities differ in what they need. A sports club wants attendance, an association wants
dues, a neighbourhood group wants neither. A community should get its areas by saying what kind
of community it is, not by working through a list of switches, and whatever that produces has to
be something the core can check, record and change under the community's own governance.

[ADR 0001](0001-technology-stack.md) keeps domains as contexts inside `occ_core` and splits an
application out only for independent dependencies or operations. It does not say where an
optional capability goes.

What is a module, where does it live, who may switch it on, and what is a template?

## Decision drivers

- The core runs with no module, and a community can lack any module.
- Switching a module on or off is the community's decision, made under its policy and logged.
- Nothing changes in a community silently.
- A small team: no more repositories and releases than necessary.
- An application built on OCC decides how setup looks; the core decides what is valid.
- A module's data stays inside the community unless a policy says otherwise.

## Considered options

1. Modules as separate applications of the umbrella in this repository, compiled in; templates
   as versioned data validated by the core.
2. Modules as contexts inside `occ_core`.
3. A repository per module from the start.
4. Third-party modules loaded at build time or run time.
5. Templates as code, or as records edited on each node.

## Decision outcome

**Option 1.**

### Modules

| # | Area | Decision |
|---|---|---|
| M1 | What a module is | A generic capability a community has or does not have. The specifications call it an extension |
| M2 | Where it lives | A separate application of the Elixir umbrella in this repository, with an explicit dependency on `occ_core`. It moves to its own repository when it needs its own maintainers, releases or licence |
| M3 | Direction of dependencies | A module depends on the core and on other modules, never on an application built on OCC. The core never depends on a module and runs with none |
| M4 | Source | Compiled in, first-party only in the first version. No code is loaded at run time. A third-party module is a fork or a pull request until a public module contract is decided |
| M5 | Availability | The node operator chooses which built-in modules are available on a node |
| M6 | Enabling | Enabling or disabling a module for a community is a right in that community's governance policy |
| M7 | Log | Every activation and deactivation is written to the governance log, with who decided and under which policy |
| M8 | Disabling | Disabling stops new writes and hides the area. It deletes nothing. Retention and export are separate, governed steps |
| M9 | Declaration | Each module declares, as data: its name and version, the modules it needs, the actions it adds to grants ([ADR 0008](0008-participant-profiles-and-grants.md)), the governance rights it adds, its setup questions with defaults, and the transfer class of each kind of record it stores |
| M10 | Privacy | A module's data is invisible to the federation adapter unless a policy says otherwise |
| M11 | Labelling | This repository lists each application as core or optional module, with a maturity: planned, experimental or stable |

### Templates

| # | Area | Decision |
|---|---|---|
| T1 | What a template is | What a setup produces: a kind of community, the modules to enable, role templates, default policies, the word used for a participant, which roles get a participant profile, the set of actions a representative holds, and the answers to the modules' setup questions |
| T2 | Ownership | OCC owns the mechanism: the format, its validation, the permission checks and the record of what was applied. An application built on OCC owns the presets and the setup experience: which kinds exist, the wording, the screens |
| T3 | Form of a preset | A versioned JSON document, validated against an OCC schema. The application ships it; the operator registers it on the node |
| T4 | The core alone | The core ships one minimal preset: no modules, a single administrator, no participant profiles. A node with no application still creates a community |
| T5 | What is stored | Applying a preset stores a snapshot of the resulting configuration on the community, with the preset's name and version as provenance. The community does not point at the preset |
| T6 | Preset updates | A changed preset reaches an existing community only through an explicit, governed change |
| T7 | Defaults | Every setup question has a default, so a setup can be finished without answering any of them |
| T8 | Transfers of control | A transfer can change the configuration. Accepting control includes answering the questions of the modules being added. Content from before keeps the audience it had |
| T9 | Operator support | A community's configuration belongs to the community. The operator's support staff see it only through time-limited access that the community's administrator grants, logged and shown to that administrator |

### Consequences

- Good: a module's actions, rights and questions are data, so a policy and a template can be
  validated against the modules a node has.
- Good: a snapshot means a question about a community is answered from the community's own
  record, not from a preset that may have changed since.
- Good: first-party only lets the module contract change while the first modules are written.
- Bad: nobody outside can add a module without a fork until a public contract exists.
- Bad: the umbrella grows by one application per module.
- The rule in ADR 0001 gains a case: an optional capability is an application from the start,
  not a context of `occ_core`.
- A community archive carries the snapshot and the data of enabled modules, and an import has
  to say what happens when the destination node lacks one of them. The
  [community archive](../specs/community-archive.md) and
  [adapter capabilities](../specs/capabilities.md) specifications define that: it is reported
  before anything is written, and the data is kept and shown to nobody.

## Pros and cons of the options

**Contexts inside `occ_core`.** Pro: least structure. Con: the core would not run without them,
and a community could not lack one.

**A repository per module.** Pro: independent releases. Con: more releases and set-up than a
small team can carry; the rule to move out later covers the need.

**Third-party modules now.** Pro: an ecosystem sooner. Con: a public contract would have to stay
stable before the first module has tested it.

**Templates as code, or edited on the node.** Con: code needs a release for every wording
change; presets edited on a node drift between nodes.

Within option 1, a community that references its preset instead of storing a snapshot was not
taken: a preset update would change communities without a governed step.

## More information

Open: the template schema and the module declaration, which are written with the first module
and not before; how a module upgrades its own tables within a release; a public module contract,
to be revisited after two modules exist; whether optional modules sit beside the core
applications in `apps/` or elsewhere (proposed: beside them, labelled).

Tests that will accompany the implementation: a node built with no module passes every core
test; a module enabled in one community leaves no route, record or right in another; enabling
without the right is refused; disabling keeps existing records exportable; an invalid preset is
rejected with the failing rule; a preset update leaves existing communities unchanged; a setup
with no question answered works; an import on a node lacking a module reports it before any data
is written.
