<!--
SPDX-FileCopyrightText: 2026 Open Communities Core contributors
SPDX-License-Identifier: CC-BY-4.0
-->

# Contributing to Open Communities Core

Thank you for considering a contribution. This document explains how the project works so that
your change can be reviewed and merged quickly.

## Ground rules

- Be kind. The [Code of Conduct](CODE_OF_CONDUCT.md) applies everywhere the project happens.
- Discuss larger changes in an issue before writing code. Architecture changes go through an
  [ADR](docs/adr/README.md).
- Security problems are reported privately; see [SECURITY.md](SECURITY.md).
- English, plain language, in code and in prose.

## Developer Certificate of Origin

Every commit must be signed off:

```bash
git commit -s -m "feat(governance): add transfer proposal state machine"
```

The `Signed-off-by: Your Name <you@example.com>` trailer certifies that you wrote the change or
have the right to submit it under the project licence, as stated in the
[Developer Certificate of Origin 1.1](https://developercertificate.org/). It does not transfer
your copyright; you keep it. Use your real name and a reachable e-mail address. Never sign off on
behalf of someone else. A DCO check runs on every pull request.

There is no Contributor License Agreement.

## Licences

- Code: AGPL-3.0-or-later. By contributing you agree your code is released under it.
- Documentation and specification text: CC-BY-4.0.
- Every file carries SPDX headers; `reuse lint` runs in CI. New dependencies are checked for
  licence compatibility and recorded in [`docs/third-party.md`](docs/third-party.md).

## Commit messages

[Conventional Commits](https://www.conventionalcommits.org/), one line:

```
type(scope): subject
```

- Types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `build`, `ci`, `perf`, `security`.
- Imperative mood, lowercase, no full stop, at most 72 characters.
- Scope is the context or area: `identity`, `communities`, `membership`, `governance`,
  `policies`, `portability`, `federation`, `web`, `adr`, `deps`.
- One commit per coherent change; each commit passes `mix precommit`.
- Do not add AI co-author trailers (see the AI policy below).

## Branches and pull requests

1. Fork or branch from `main`: `feat/short-topic`, `fix/short-topic`, `docs/short-topic`.
2. Run `mix precommit` before pushing.
3. Open a pull request with the template filled in: what changed, how it was checked, and the AI
   assistance declaration.
4. A maintainer reviews. Address comments with new commits; the history is rebased on merge.
5. `main` is protected: a pull request with passing CI and DCO checks is required, and a
   maintainer reviews every change before merging. Merges are rebases, so history stays linear.

## Development setup

```bash
docker compose up -d
mix setup
mix test
```

- `mix lint` runs `format --check-formatted`, `credo --strict`, `sobelow` and `deps.audit`.
- `mix precommit` compiles with warnings as errors, checks unused dependencies, formats, runs
  Credo and the tests.
- Tests use PostgreSQL. Set `OCC_DB_PORT` in `.env` if port 5432 is taken.

## Code conventions

- Contexts (`OCC.Identity`, `OCC.Communities`, …) expose functions, not schemas, to each other.
- The federation adapter depends on the domain, never the reverse. Private communities must be
  invisible to it by construction.
- Access control is enforced in the domain layer, not only in the API.
- No personal data in logs, error messages or URLs.
- Every public function has a `@doc` and a typespec; every change that touches behaviour has a
  test.

## Policy on AI assistance

- Using AI tools (code assistants, chat models) is allowed.
- The human contributor is responsible for the code, its tests, its security and its licence
  compliance, exactly as for any other code.
- AI-generated code is reviewed by the contributor before it is submitted.
- Substantial AI assistance is declared in the pull request description using the template's
  checkbox. Minor help (completions, small refactors) needs no declaration.
- Do not add `Co-Authored-By` trailers for AI tools. That trailer identifies co-authors, and a
  tool does not hold the legal status of a contributor.
- The DCO sign-off always belongs to the person taking responsibility for the contribution.

## Architecture Decision Records

Decisions that affect contributors live in [`docs/adr/`](docs/adr/) in
[MADR](https://adr.github.io/madr/) format. Propose a new one by pull request; it is `Proposed`
until a maintainer marks it `Accepted`. Superseding an ADR is done by a new ADR, never by editing
history.

## Releases

Semantic Versioning; changes are recorded in [CHANGELOG.md](CHANGELOG.md) under `Unreleased`
as they are merged. Releases are tagged and signed by a maintainer.
