# Operator Guide

Этот документ описывает, как вести `specs/` в двух режимах: greenfield и brownfield.

## Purpose

`specs/` — это operational memory и source-of-truth слой проекта.

Он разделён на:
- **канон**: `PRD.md`, `TECHSPEC.md`, `MILESTONES.md`, `ADR/**`
- **операционный слой**: `STATE.md`, `backlog/**`, `tasks/**`
- **proposal/change слой**: `changes/**`

Главный принцип: proposal-артефакты не должны подменять канон. Канон остаётся единственным runtime-context для coding agent после merge.

## Two Modes

### 1. Greenfield

Используй greenfield path, когда строится новый baseline продукта или крупный участок системы ещё не описан вообще.

Основной маршрут:

`PRD -> TECHSPEC -> MILESTONE_ROLE -> BACKLOG_ROLE -> CODING_ROLE -> SPEC_ROLE / DEV_SYNC_ROLE`

Смысл:
- сначала формируется общая truth-model продукта и системы;
- затем roadmap на уровне milestones;
- затем task decomposition и реализация.

### 2. Brownfield

Используй brownfield path, когда продукт уже живёт, а новая фича или изменение должны встраиваться в существующий baseline без переписывания всей истины.

Основной маршрут:

`CHANGE_INTAKE_ROLE -> PRD_DELTA_ROLE? -> TECHSPEC_DELTA_ROLE -> CHANGE_MERGE_ROLE -> BACKLOG_ROLE -> CODING_ROLE -> SPEC_ROLE / DEV_SYNC_ROLE`

Смысл:
- сначала описывается delta относительно текущего baseline;
- затем выполняется controlled merge в канон;
- только потом изменение декомпозируется в backlog.

## Routing Rule

Поддерживаются только два класса изменений:

### `tiny`

Идёт напрямую в обычный spec/backlog flow.

Типичные признаки:
- багфикс;
- локальный refactor;
- узкий contract/data patch;
- небольшой UI patch;
- follow-up к уже принятому решению;
- не меняет user flow, domain boundaries, roadmap или крупный implementation slice.

Маршрут:

`INBOX_ROLE -> backlog/spec patch -> CODING_ROLE`

### `major`

Идёт через change pack.

Типичные признаки:
- меняется user flow или scope;
- добавляется новый bounded context / subsystem;
- меняются API/contracts/events в широкой зоне;
- появляются миграции, rollout constraints, новые NFR;
- change нужно резать на несколько increments;
- изменение влияет на roadmap/milestones;
- есть риск переписать канон слишком широко.

Маршрут:

`INBOX_ROLE -> CHANGE_INTAKE_ROLE -> delta docs -> CHANGE_MERGE_ROLE -> BACKLOG_ROLE`

### `medium`

Не поддерживается намеренно.

Если есть сомнение между `tiny` и `major`, выбирай `major`.

## Canonical Documents

### PRD
- отвечает за `what/why`;
- хранит user-visible behavior, scope, flows, invariants;
- не хранит field names, contracts, thresholds.

### TECHSPEC
- отвечает за `how`;
- хранит architecture, data model, lifecycle, contracts, integrations;
- не хранит backlog decomposition и roadmap seeds.

### MILESTONES
- хранит baseline roadmap и milestone-level increments;
- не обязан содержать каждый tactical patch;
- для brownfield changes патчится только при реальном roadmap impact;
- если новый milestone появляется в pipeline, его можно кратко дописать.

### ADR
- фиксирует архитектурные решения и trade-offs;
- старые ADR не переписываются задним числом без необходимости;
- если решение заменено, используй superseding ADR.

## Change Packs

Для `major` изменений используй `specs/changes/CHG-XXX-<slug>/`.

Рекомендуемая структура:

```text
specs/changes/CHG-XXX-<slug>/
  README.md
  PRD_DELTA.md
  TECHSPEC_DELTA.md
  MERGE_PLAN.md
```

### Status Lifecycle

- `draft` — change исследуется, канон не трогаем
- `approved` — delta согласована
- `merged` — изменения вмержены в канон
- `landed` — реализация доставлена
- `rejected` — change отменён

### Merge Rules

- untouched sections не переписывать;
- changed sections патчить адресно;
- новые trade-off решения выносить в ADR;
- `MILESTONES.md` патчить только если change меняет roadmap;
- backlog генерировать только после merge.

## Backlog Rules

- `ACTIVE.md` содержит только open tasks;
- completed work уходит в archive/task reports;
- `major` changes не попадают в `ACTIVE.md`, пока change pack не approved/merged;
- backlog decomposition всегда строится от канона или от уже approved/merged delta, а не от сырых входящих идей.

## Practical Default

Если задача кажется достаточно большой, чтобы случайно переписать PRD/TECHSPEC/MILESTONES шире, чем нужно, не трогай канон сразу. Сначала создай change pack и пройди brownfield flow.
