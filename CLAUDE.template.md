<!-- Template for CLAUDE.md (project root) — project-specific context for coding agents.
     Highest-priority source of truth (see CODING_ROLE.md).
     Keep concise: agent reads this first every session. -->

# <Project Name> — Project Context

<!-- One-sentence product description. Tech stack summary. -->

## Specs

Specifications and project state live in `specs/`. Read `specs/AGENTS.md` for universal coding conventions.

## Key Modules

<!-- Brief description of major code modules and their responsibilities.
     Helps the agent orient quickly. -->

- `<module-path>` — <!-- responsibility -->

## Special Rules

<!-- Project-specific rules not covered by AGENTS.md. Examples:
     - ORM/database mapping requirements
     - Ignored/obsolete directories
     - Integration-specific constraints -->

## Verification

Before finishing any task:

<!-- Build, test, lint commands. Agent runs these to confirm task completion. -->

- `<build command>`
- `<test command>`
- `<lint/verify command>`
