<!--
SPDX-FileCopyrightText: 2026 Open Communities Core contributors
SPDX-License-Identifier: CC-BY-4.0
-->

# Architecture Decision Records

Decisions that affect how OCC is built, in [MADR](https://adr.github.io/madr/) format. An ADR is
immutable once accepted; a change is a new ADR that supersedes it.

| ADR | Title | Status |
|---|---|---|
| [0001](0001-technology-stack.md) | Technology stack and architectural boundaries | Proposed |
| [0008](0008-participant-profiles-and-grants.md) | Participant profiles and grants | Accepted |
| [0009](0009-modules-and-templates.md) | Optional modules and community templates | Accepted |

Numbers are not consecutive: a number is reserved when a decision is opened, and its record is
published here once it is accepted.

## Lifecycle

`Proposed` → `Accepted` (by a maintainer, after discussion in the pull request) → optionally
`Superseded by ADR-NNNN` or `Deprecated`.

## Template

```markdown
# NNNN — Title

- Status: Proposed | Accepted | Superseded by ADR-NNNN | Deprecated
- Date: YYYY-MM-DD
- Deciders: names

## Context and problem statement
## Decision drivers
## Considered options
## Decision outcome
### Consequences
## Pros and cons of the options
## More information
```
