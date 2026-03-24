#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./ralf.sh <target_done_tasks> [max_loop_iterations]
#
# Examples:
#   ./ralf.sh 2
#   ./ralf.sh 2 30

TARGET_DONE="${1:-1}"

if ! [[ "$TARGET_DONE" =~ ^[1-9][0-9]*$ ]]; then
  echo "First argument must be a positive integer (target DONE tasks), got: $TARGET_DONE"
  exit 1
fi

MAX_ITERS="${2:-$((TARGET_DONE * 10))}"

if ! [[ "$MAX_ITERS" =~ ^[1-9][0-9]*$ ]]; then
  echo "Second argument must be a positive integer (max loop iterations), got: $MAX_ITERS"
  exit 1
fi

PROMPT_FILE="${PROMPT_FILE:-./specs/roles/CODING_ROLE.md}"
LOG_DIR="${LOG_DIR:-./.ralf-logs}"
MAX_AGENT_TURNS="${MAX_AGENT_TURNS:-200}"
NOOP_LIMIT="${NOOP_LIMIT:-2}"
MAX_BUDGET_USD="${MAX_BUDGET_USD:-}"

mkdir -p "$LOG_DIR"

# Optional proxy bootstrap for non-interactive shell runs.
# This script runs via bash, so zsh-only function wrappers are not available.
if [[ -f "$HOME/.proxy_secrets" ]]; then
  # shellcheck disable=SC1090
  source "$HOME/.proxy_secrets"
fi

# Fallback: allow setting one URL and mirror it to all proxy vars.
if [[ -n "${CLAUDE_PROXY_URL:-}" ]]; then
  export HTTP_PROXY="${HTTP_PROXY:-$CLAUDE_PROXY_URL}"
  export HTTPS_PROXY="${HTTPS_PROXY:-$CLAUDE_PROXY_URL}"
fi

# Keep lowercase variants in sync for tools that read only one style.
if [[ -n "${HTTP_PROXY:-}" && -z "${http_proxy:-}" ]]; then
  export http_proxy="$HTTP_PROXY"
fi
if [[ -n "${HTTPS_PROXY:-}" && -z "${https_proxy:-}" ]]; then
  export https_proxy="$HTTPS_PROXY"
fi

# Claude CLI respects env proxy only when this flag is enabled.
if [[ -n "${HTTP_PROXY:-}${HTTPS_PROXY:-}${http_proxy:-}${https_proxy:-}" ]]; then
  export NODE_USE_ENV_PROXY="${NODE_USE_ENV_PROXY:-1}"
fi

if [[ ! -f "$PROMPT_FILE" ]]; then
  echo "Prompt file not found: $PROMPT_FILE"
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required"
  exit 1
fi

# Внешний loop должен быть единственным loop-механизмом.
export CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1
export CLAUDE_CODE_DISABLE_CRON=1
export NO_PROXY="localhost,127.0.0.1"

TMP_GUARD="$(mktemp)"
trap 'rm -f "$TMP_GUARD"' EXIT

cat > "$TMP_GUARD" <<'EOF'
Ты работаешь внутри внешнего non-interactive loop.

Дополнительный контракт цикла:
- Выполни не больше одной атомарной backlog-задачи за итерацию.
- Если исполнимой задачи нет или нужны ответы пользователя, НЕ выдумывай работу. Верни статус NEEDS_USER и конкретные вопросы.
- Если ты только читал, анализировал, планировал, сравнивал варианты или писал рассуждения, но не сделал содержательных изменений в репозитории, ты ОБЯЗАН вернуть CONTINUE, а не DONE.
- Не создавай коммиты даже если изменения готовы.
- DONE разрешён только если одновременно выполнено всё:
  1) задача реально доведена до конца в рамках этой итерации;
  2) обновлён specs/STATE.md;
  3) обновлён specs/backlog/ACTIVE.md;
  4) создан или обновлён specs/tasks/<TASK-ID>.md;
  5) есть хотя бы одно содержательное изменение вне bookkeeping-файлов.
- VERIFIED — для задач-верификаций (аудит, проверка pipeline, smoke-test), которые не требуют кодовых изменений.
  Требования 1-4 те же, что у DONE. Требование 5 НЕ применяется.
- Bookkeeping-файлы: specs/STATE.md, specs/backlog/ACTIVE.md, specs/tasks/<TASK-ID>.md
- Финальный ответ должен быть ТОЛЬКО валидным JSON по схеме, без markdown и без пояснений вокруг JSON.
EOF

SCHEMA='{
  "type":"object",
  "properties":{
    "status":{"type":"string","enum":["DONE","VERIFIED","CONTINUE","NEEDS_USER","ERROR"]},
    "task_id":{"type":"string"},
    "summary":{"type":"string"},
    "questions":{"type":"array","items":{"type":"string"}},
    "touched_files":{"type":"array","items":{"type":"string"}}
  },
  "required":["status","task_id","summary","questions","touched_files"],
  "additionalProperties":false
}'

has_diff() {
  [[ -n "$(git status --porcelain)" ]]
}

all_changed_paths() {
  git status --porcelain -uall | awk '{print $2}' | awk 'NF' | sort -u
}

commit_if_changed() {
  local msg="$1"
  if has_diff; then
    git add -A
    git commit -m "$msg" || true
  fi
}

NOOP_STREAK=0
DONE_COUNT=0

for ((i=1; i<=MAX_ITERS; i++)); do
  echo "=== ITERATION $i | DONE $DONE_COUNT/$TARGET_DONE ==="

  OUT_FILE="$LOG_DIR/iter-$i.json"
  QUERY="$(cat "$PROMPT_FILE")"

  CLAUDE_ARGS=(
    -p "$QUERY"
    --append-system-prompt-file "$TMP_GUARD"
    --dangerously-skip-permissions
    --no-session-persistence
    --output-format json
    --json-schema "$SCHEMA"
    --max-turns "$MAX_AGENT_TURNS"
  )

  if [[ -n "$MAX_BUDGET_USD" ]]; then
    CLAUDE_ARGS+=(--max-budget-usd "$MAX_BUDGET_USD")
  fi

  set +e
  claude "${CLAUDE_ARGS[@]}" > "$OUT_FILE"
  CLAUDE_EXIT=$?
  set -e

  cat "$OUT_FILE"

  if [[ $CLAUDE_EXIT -ne 0 ]]; then
    echo "Claude exited with code $CLAUDE_EXIT"
    commit_if_changed "ralf: failed iter $i"
    continue
  fi

  PAYLOAD="$(jq -c '.structured_output // {}' "$OUT_FILE")"
  STATUS="$(jq -r '.status // "ERROR"' <<< "$PAYLOAD")"
  TASK_ID="$(jq -r '.task_id // ""' <<< "$PAYLOAD")"

  if has_diff; then
    NOOP_STREAK=0
  else
    NOOP_STREAK=$((NOOP_STREAK + 1))
  fi

  case "$STATUS" in
    NEEDS_USER)
      commit_if_changed "ralf: needs-user${TASK_ID:+ [$TASK_ID]} iter $i"
      echo "Needs user input:"
      jq -r '.structured_output.questions[]?' "$OUT_FILE"
      exit 2
      ;;

    DONE)
      if ! has_diff; then
        echo "DONE rejected: repository has no changes"
        exit 3
      fi

      CHANGED="$(all_changed_paths)"

      grep -Fxq "specs/STATE.md" <<< "$CHANGED" || {
        echo "DONE rejected: specs/STATE.md not updated"
        exit 3
      }

      grep -Fxq "specs/backlog/ACTIVE.md" <<< "$CHANGED" || {
        echo "DONE rejected: specs/backlog/ACTIVE.md not updated"
        exit 3
      }

      if [[ -z "$TASK_ID" || "$TASK_ID" == "null" ]]; then
        echo "DONE rejected: task_id is empty"
        exit 3
      fi

      grep -Fxq "specs/tasks/${TASK_ID}.md" <<< "$CHANGED" || {
        echo "DONE rejected: specs/tasks/${TASK_ID}.md not updated"
        exit 3
      }

      SUBSTANTIVE="$(
        printf '%s\n' "$CHANGED" \
          | grep -Ev '^specs/STATE\.md$|^specs/backlog/ACTIVE\.md$|^specs/tasks/[^/]+\.md$' \
          || true
      )"

      if [[ -z "$SUBSTANTIVE" ]]; then
        echo "DONE rejected: only bookkeeping files changed"
        exit 3
      fi

      DONE_COUNT=$((DONE_COUNT + 1))
      commit_if_changed "ralf: ${TASK_ID} (done $DONE_COUNT/$TARGET_DONE, iter $i)"

      echo "Completed tasks: $DONE_COUNT/$TARGET_DONE"

      if [[ "$DONE_COUNT" -ge "$TARGET_DONE" ]]; then
        echo "Loop finished: completed $DONE_COUNT task(s)"
        exit 0
      fi
      ;;

    VERIFIED)
      CHANGED="$(all_changed_paths)"

      grep -Fxq "specs/STATE.md" <<< "$CHANGED" || {
        echo "VERIFIED rejected: specs/STATE.md not updated"
        exit 3
      }

      grep -Fxq "specs/backlog/ACTIVE.md" <<< "$CHANGED" || {
        echo "VERIFIED rejected: specs/backlog/ACTIVE.md not updated"
        exit 3
      }

      if [[ -z "$TASK_ID" || "$TASK_ID" == "null" ]]; then
        echo "VERIFIED rejected: task_id is empty"
        exit 3
      fi

      grep -Fxq "specs/tasks/${TASK_ID}.md" <<< "$CHANGED" || {
        echo "VERIFIED rejected: specs/tasks/${TASK_ID}.md not updated"
        exit 3
      }

      DONE_COUNT=$((DONE_COUNT + 1))
      commit_if_changed "ralf: ${TASK_ID} (verified $DONE_COUNT/$TARGET_DONE, iter $i)"

      echo "Completed tasks: $DONE_COUNT/$TARGET_DONE (verified)"

      if [[ "$DONE_COUNT" -ge "$TARGET_DONE" ]]; then
        echo "Loop finished: completed $DONE_COUNT task(s)"
        exit 0
      fi
      ;;

    CONTINUE)
      if [[ "$NOOP_STREAK" -ge "$NOOP_LIMIT" ]]; then
        echo "Stopped: $NOOP_STREAK consecutive no-op iterations"
        exit 4
      fi

      commit_if_changed "ralf: checkpoint${TASK_ID:+ [$TASK_ID]} iter $i"
      ;;

    ERROR)
      commit_if_changed "ralf: error${TASK_ID:+ [$TASK_ID]} iter $i"
      echo "Agent returned ERROR"
      exit 5
      ;;

    *)
      echo "Unknown status: $STATUS"
      exit 6
      ;;
  esac
done

echo "Reached max iterations: $MAX_ITERS, completed only $DONE_COUNT/$TARGET_DONE task(s)"
exit 1
