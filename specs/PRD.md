# PRD — Product Requirements Document

## Document Boundary

PRD описывает **что** продукт делает и **зачем**, с точки зрения пользователя и бизнеса.

### Пишем здесь

- Vision, problem statement, target user
- Product principles и invariants (на уровне "система гарантирует X")
- User flows и capabilities (что пользователь может делать)
- Scope in/out, success criteria
- Экраны и их назначение (что видит пользователь)

### НЕ пишем здесь — перенаправляем

- Имена полей, enum values, thresholds → **TECHSPEC**
- Data model, entity schemas, lifecycle state machines → **TECHSPEC**
- Route tables, UI layout mechanics, carousel/overlay logic → **TECHSPEC**
- API contracts, provider contracts → **TECHSPEC**
- Extraction rules, anti-patterns, pipeline algorithms → **TECHSPEC**
- Решения с альтернативами и trade-offs → **ADR**

### Лакмусовый тест
>
> Если в тексте появляется имя поля (`executionPrimaryRef`), enum value (`implemented_with_issues`), threshold (`0.95`), или формула — это **не PRD**. Перенеси в TECHSPEC.
>
> ADR в PRD — только ссылка и одно предложение о продуктовом следствии. Не пересказывай содержимое ADR.

⸻

TODO твой PRD
