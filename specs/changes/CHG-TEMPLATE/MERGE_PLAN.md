# Merge Plan

## Preconditions

- change pack status = approved
- blocking open questions closed
- ADR candidates resolved or explicitly deferred

## Canonical Patch List

- `PRD.md`: ...
- `TECHSPEC.md`: ...
- `MILESTONES.md`: ...
- `ADR/**`: ...

## Merge Operations

1. append / replace / split only in affected sections
2. leave untouched sections unchanged
3. add ADR for lasting trade-offs
4. patch milestones only if roadmap changed

## Post-Merge

- set change pack status to `merged`
- confirm whether `BACKLOG_ROLE` can start
- list first recommended implementation slices
