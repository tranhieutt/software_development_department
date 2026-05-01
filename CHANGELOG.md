# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased] - 2026-05-01

### Removed
- Deleted startup-business skill (empty boilerplate)

### Changed
- Rewrote hybrid-cloud-architect: 170-line catalog to 8-step workflow with decision matrices
- Rewrote deployment-engineer: 173-line catalog to pipeline design workflow with code examples
- Rewrote 5 thin skills with real domain content: react-native-architecture, dotnet-backend-patterns, microservices-patterns, sql-optimization-patterns, ui-spec
- Removed generic boilerplate headers from 7 skills
- Removed broken resources/implementation-playbook.md references from 6 skills
- Fixed 6 naming inconsistencies (architecture-decision to architecture-decision-records)
- Fixed vertical-slicing typo (/vertical-slice to /vertical-slicing)

### Added
- Cross-references between changelog and patch-notes skills
- 4 new validation checks in validate-skills.ps1 and validate-skills.sh (type validation, boilerplate detection, broken references, minimum content length)
