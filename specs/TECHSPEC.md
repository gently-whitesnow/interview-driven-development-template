# TECHSPEC — Technical Specification

## Document Boundary

TECHSPEC описывает **как** система устроена: архитектура, data model, contracts, lifecycle, integrations.

### Пишем здесь
- Архитектура, bounded contexts, зависимости между модулями
- Data model: entities, fields, constraints, enums
- Lifecycle state machines и transition rules
- API contracts, WebSocket events, provider contracts
- Integration specs (CLI, GitHub, AI providers)
- NFR, testing strategy, operational invariants
- Pipeline algorithms, extraction rules, thresholds

### НЕ пишем здесь — перенаправляем
- Зачем продукт существует, vision, problem statement → **PRD**
- Product scope decisions (in/out) → **PRD**
- User stories ("пользователь нажимает / видит / может") → **PRD**
- Product philosophy и high-level principles → **PRD**
- System-level acceptance criteria (user-facing) → **PRD**
- Project roadmap, backlog guidance, milestone ordering → **MILESTONES.md**
- Решения с альтернативами и trade-offs → **ADR**
- Current implementation status snapshots → **STATE.md**

### Лакмусовый тест
> Если в тексте написано "пользователь может / видит / нажимает" — это **не TECHSPEC**. Перенеси в PRD.
>
> Если описываешь "почему X, а не Y" — это **не TECHSPEC**. Создай ADR.
>
> Если описываешь "что уже реализовано на сегодня" — это **не TECHSPEC**. Обнови STATE.md.

TODO твой TECHSPEC
