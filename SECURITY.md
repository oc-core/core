<!--
SPDX-FileCopyrightText: 2026 Open Communities Core contributors
SPDX-License-Identifier: CC-BY-4.0
-->

# Security policy

OCC is meant to hold private communities, some of them with data about children. We take
reports seriously and we prefer to hear about a problem from you before anyone else does.

## Reporting a vulnerability

- Use GitHub's private vulnerability reporting on this repository
  ("Security" tab → "Report a vulnerability"), or
- e-mail the maintainers listed in [MAINTAINERS.md](MAINTAINERS.md) with "SECURITY" in the
  subject. A dedicated address and a PGP key will be published here before the first release.

Please do not open a public issue for a security problem.

Include what you can: affected component and version or commit, steps to reproduce, impact,
and whether the issue is already public. You will get an acknowledgement within 3 working days.

## Coordinated disclosure

- We confirm the issue, agree a severity with you and work on a fix.
- We aim to release a fix within 90 days of the report; critical issues sooner.
- We publish an advisory (GitHub Security Advisory) crediting you, unless you prefer otherwise,
  once a fix is available or the 90 days have passed.
- We ask that you give us that window before disclosing publicly, and that you avoid accessing
  data that is not yours, degrading service, or testing against instances you do not control.

## Scope

In scope: this repository, its released artefacts and container images. Particularly interesting
to us: anything that lets private community data reach the federation layer, bypasses governance
rules, forges federated identities, or breaks HTTP signature verification.

Out of scope: third-party instances run by others, social engineering, denial of service by
volume.

## Supported versions

There is no release yet. Once there is, this table lists which versions receive fixes.

| Version | Supported |
|---|---|
| `main` | yes, as development branch |
