# Change Packs

`specs/changes/` хранит proposal-артефакты для **major brownfield changes**.

## Rule

Пока change pack находится в статусе `draft` или `approved`, канонические `PRD.md` / `TECHSPEC.md` не должны переписываться wholesale под новую фичу.

Сначала описывается delta, затем выполняется controlled merge в канон, и только после этого change идёт в backlog/coding.

## Structure

```text
specs/changes/CHG-XXX-<slug>/
  README.md
  PRD_DELTA.md
  TECHSPEC_DELTA.md
  MERGE_PLAN.md
```

Все файлы обязательны только если действительно нужны:
- user-visible major change обычно требует `PRD_DELTA.md` и `TECHSPEC_DELTA.md`;
- purely technical major change может обойтись без `PRD_DELTA.md`;
- `MERGE_PLAN.md` обязателен перед merge.

## Statuses

- `draft`
- `approved`
- `merged`
- `landed`
- `rejected`

## Template

Скопируй `specs/changes/CHG-TEMPLATE/` в новый `CHG-XXX-<slug>/` и заполни дельту относительно актуального baseline.
