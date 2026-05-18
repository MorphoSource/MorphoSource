# MorphoSource Development Guide

## Project Overview
MorphoSource is a Ruby on Rails application for managing and sharing 3D data from
biological specimens and cultural heritage objects. It is built on the Hyrax/Samvera engine and uses Valkyrie for
metadata and file storage abstraction.

## Branch & PR Rules
- Never push directly to `main` or `dev`
- Always branch from `dev` using the pattern `claude/<short-description>`
- Always target `dev` as the PR base branch unless the issue explicitly specifies otherwise
- Use `gh` CLI for all GitHub operations (creating PRs, commenting, etc.)

## Key Dependencies

### Hyrax
A Samvera community Rails engine that provides the core repository framework.
Source: https://github.com/samvera/hyrax/tree/v5.0.5
Reference this codebase when understanding engine behavior, overrides, or inherited functionality.

### Valkyrie
Provides the metadata and file storage abstraction layers that both MorphoSource and
Hyrax depend on heavily.
Source: https://github.com/samvera/valkyrie
Reference this codebase when working with resource persistence, adapters, or file storage.

## Workflow for Issue-Driven Development
When assigned to or mentioned on a GitHub issue:
1. **Plan first** — unless the change is trivially small (e.g. a one-line fix or typo),
   post a comment on the issue outlining your proposed approach before writing any code.
   Wait for explicit approval from a maintainer before proceeding.
2. **Then implement** — once the plan is approved, create a branch and open a PR per the
   branch rules above.

## Notes
- Automated tests cannot be run in CI for Claude-initiated PRs — PRs should be opened
  for human review and test runs will be triggered by the CI pipeline automatically.
