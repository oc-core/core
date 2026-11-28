<!--
SPDX-FileCopyrightText: 2026 Open Communities Core contributors
SPDX-License-Identifier: CC-BY-4.0
-->

# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Phoenix umbrella skeleton with the `occ_core` domain application and the `occ_core_web`
  JSON API application.
- Empty domain contexts documenting the boundaries: Identity, Communities, Membership,
  Governance, Policies, Portability, Federation.
- ADR-001: technology stack.
- Governance policy specification, draft 0.1, with a JSON Schema and three example policies.
- Community archive specification, draft 0.1, with JSON Schemas and a sample archive.
- Privacy modes specification, draft 0.1, with a JSON Schema and one example setting per mode.
- Adapter capabilities specification, draft 0.1, with JSON Schemas for the capability
  declaration and the pre-flight report, three example declarations and one example report.
- Project files: licences (AGPL-3.0-or-later, CC-BY-4.0, CC0-1.0, Apache-2.0 for specification schemas), REUSE compliance,
  contributing guide with DCO and AI policy, code of conduct, security policy, governance.
- Continuous integration: format, Credo, compile with warnings as errors, tests, Sobelow,
  dependency audit, REUSE lint, DCO check.

[Unreleased]: https://github.com/oc-core/core/commits/main
