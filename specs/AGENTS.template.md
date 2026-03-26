<!-- Template for specs/AGENTS.md — universal coding conventions.
     These rules apply to ALL agents working on the project.
     Keep portable. Project-specific rules go in CLAUDE.md. -->

# AGENTS — Universal Coding Conventions

## General

<!-- Language-agnostic rules. Examples: -->
- No file larger than 300 lines — decompose if exceeded.
- When integrating with third-party services, use web search to verify current API docs.

## <Primary Language>

<!-- Language-specific conventions. Suggested topics:
     - Error handling strategy (exceptions vs result types)
     - Naming conventions, wire-format rules
     - Test naming patterns
     - DI/IoC registration defaults
     - Async method conventions -->

## <Secondary Language / Frontend>

<!-- Frontend or secondary stack conventions. Suggested topics:
     - Theme defaults (light-first, dark-capable)
     - Icon library choice
     - State management patterns
     - Semantic color usage -->

## Testing

<!-- Cross-cutting test conventions. Suggested topics:
     - Test display name format
     - Prohibited patterns (e.g., no Task.Delay in tests)
     - Required test categories -->
