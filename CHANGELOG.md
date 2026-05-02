# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased] - 2026-05-02

### Added
- New `markdown-injection-scanner` skill for .md file security audit (XSS, prompt injection, script injection, obfuscated payloads)
- New `.claude/rules/error-handling.md` — global error handling strategy (error classification, throw vs return, error types, global handler, retry, validation format)
- New `.claude/rules/logging-standards.md` — global logging & observability standards (structured JSON format, log levels, request tracing, metrics, rotation/retention)

### Fixed
- Resolved 14 issues in hooks system: security hardening, cross-platform compatibility, performance improvements
- Suppressed shellcheck warnings SC2317, SC2012 in auto-dream.sh and session-start.sh
- Rewrote `.claude/rules/test-standards.md` examples from GDScript to JavaScript to match project stack
- Rewrote `.claude/rules/network-code.md` from game netcode patterns to HTTP/REST networking standards
- Resolved `src/components/**` path overlap between `frontend-code.md` and `ui-code.md`
- Resolved `src/config/**` path ambiguity between `data-files.md` and `secrets-config.md` with explicit boundary declarations

### Removed
- Deleted startup-business skill (empty boilerplate)
- Removed game netcode patterns from `network-code.md` (client prediction, rollback, host migration, replication strategy)
- Removed `src/components/**` from `ui-code.md` paths (now governed solely by `frontend-code.md`)
- Removed `src/config/**` from `data-files.md` paths (now governed solely by `secrets-config.md`)

### Changed
- Standardized YAML frontmatter across all `.claude/rules/` files: `api-code.md`, `database-code.md`, `frontend-code.md`, `secrets-config.md`, `git-push.md`
- Merged UI accessibility rules from `ui-code.md` into `frontend-code.md` (ARIA labels, prefers-reduced-motion, colorblind-safe, loading states, viewport testing)
- Added cross-references between related rules (`ui-code.md` ↔ `frontend-code.md`, `data-files.md` ↔ `secrets-config.md`)
- Expanded `network-code.md` paths to include `src/http/**`, `src/services/**`
- Rewrote hybrid-cloud-architect: 170-line catalog to 8-step workflow with decision matrices
- Rewrote deployment-engineer: 173-line catalog to pipeline design workflow with code examples
- Rewrote 5 thin skills with real domain content: react-native-architecture, dotnet-backend-patterns, microservices-patterns, sql-optimization-patterns, ui-spec
- Removed generic boilerplate headers from 7 skills
- Removed broken resources/implementation-playbook.md references from 6 skills
- Fixed 6 naming inconsistencies (architecture-decision to architecture-decision-records)
- Fixed vertical-slicing typo (/vertical-slice to /vertical-slicing)
- Cross-references between changelog and patch-notes skills
- 4 new validation checks in validate-skills.ps1 and validate-skills.sh (type validation, boilerplate detection, broken references, minimum content length)
