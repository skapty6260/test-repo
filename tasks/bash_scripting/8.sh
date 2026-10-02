#!/usr/bin/env bash
set -euo pipefail

# ─── Цвета ────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
MAGENTA='\033[1;35m'
BOLD='\033[1m'
NC='\033[0m'

# ─── Проверка зависимостей (только curl) ─────────────────
if ! command -v curl >/dev/null 2>&1; then
    echo -e "${RED}Ошибка: утилита 'curl' не установлена.${NC}" >&2
    echo -e "${YELLOW}Установите: sudo apt install curl${NC}" >&2
    exit 1
fi

# ─── Проверка аргумента ───────────────────────────────────
if [[ $# -ne 1 ]]; then
    echo -e "${YELLOW}Использование: $0 <owner/repo>${NC}"
    echo -e "${YELLOW}Пример:       $0 tensorflow/tensorflow${NC}"
    exit 1
fi

REPO="$1"

# ─── Запрос к GitHub API ──────────────────────────────────
API_URL="https://api.github.com/repos/${REPO}"
TMP_JSON=$(mktemp)
trap 'rm -f "$TMP_JSON"' EXIT

HTTP_CODE=$(curl -s -o "$TMP_JSON" -w "%{http_code}" \
    -H "Accept: application/vnd.github+json" \
    -A "bash-github-analyzer" \
    "$API_URL")

case "$HTTP_CODE" in
    200) ;;
    404)
        echo -e "${RED}Ошибка: репозиторий '$REPO' не найден.${NC}" >&2
        exit 2
        ;;
    403)
        echo -e "${RED}Ошибка: превышен лимит запросов к GitHub API.${NC}" >&2
        echo -e "${YELLOW}Подождите час или используйте токен (GITHUB_TOKEN).${NC}" >&2
        exit 3
        ;;
    *)
        echo -e "${RED}Ошибка API (HTTP $HTTP_CODE).${NC}" >&2
        exit 4
        ;;
esac

# ─── Парсер JSON без jq ───────────────────────────────────
# Достаёт значение по ключу верхнего уровня.
# Работает для плоских полей вида "key": value или "key": "value".
json_get() {
    local key="$1"
    # 1) убрать переводы строк, чтобы поле не разорвалось
    # 2) найти "key":  и взять следующее значение до , или }
    tr -d '\n' < "$TMP_JSON" \
        | grep -o "\"${key}\"[[:space:]]*:[[:space:]]*\(\"[^\"]*\"\|[^,}]*\)" \
        | head -n1 \
        | sed -E "s/^\"${key}\"[[:space:]]*:[[:space:]]*//; s/^\"//; s/\"$//; s/[[:space:]]+$//"
}

NAME=$(json_get "full_name")
STARS=$(json_get "stargazers_count")
FORKS=$(json_get "forks_count")
ISSUES=$(json_get "open_issues_count")
AUTHOR=$(json_get "owner")      # для вложенного .owner.login нужен отдельный проход
PUSHED=$(json_get "pushed_at")

# owner — вложенный объект, достаём login отдельно
AUTHOR=$(tr -d '\n' < "$TMP_JSON" \
    | grep -o '"owner"[[:space:]]*:[[:space:]]*{[^}]*}' \
    | grep -o '"login"[[:space:]]*:[[:space:]]*"[^"]*"' \
    | head -n1 \
    | sed -E 's/.*"login"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/')

# ─── Значения по умолчанию, если что-то не спарсилось ─────
NAME=${NAME:-$REPO}
STARS=${STARS:-0}
FORKS=${FORKS:-0}
ISSUES=${ISSUES:-0}
AUTHOR=${AUTHOR:-unknown}

# ─── Форматирование чисел с пробелами (182347 -> 182 347) ─
fmt() {
    local n="$1"
    # убрать возможные нецифровые символы
    n=$(printf '%s' "$n" | tr -dc '0-9')
    [[ -z "$n" ]] && n=0
    printf '%s' "$n" | sed -E ':a; s/([0-9])([0-9]{3})\b/\1 \2/; ta'
}

STARS_F=$(fmt "$STARS")
FORKS_F=$(fmt "$FORKS")
ISSUES_F=$(fmt "$ISSUES")

# ─── Цвет issues: >100 — красный, иначе жёлтый ────────────
if (( ISSUES > 100 )); then
    ISSUES_COLOR="$RED"
else
    ISSUES_COLOR="$YELLOW"
fi

# ─── «Свежесть» обновления ────────────────────────────────
# date -d понимает ISO 8601 в GNU date (Linux/WSL/Git Bash обычно GNU)
PUSH_TS=$(date -d "$PUSHED" +%s 2>/dev/null || echo 0)
NOW_TS=$(date +%s)

if (( PUSH_TS == 0 )); then
    ACTIVITY="Неизвестно"
    ACTIVITY_COLOR="$YELLOW"
    AGO="—"
else
    DIFF_H=$(( (NOW_TS - PUSH_TS) / 3600 ))

    if   (( DIFF_H < 24 ));    then ACTIVITY="Высокая";  ACTIVITY_COLOR="$GREEN"
    elif (( DIFF_H < 24*30 )); then ACTIVITY="Средняя";  ACTIVITY_COLOR="$YELLOW"
    else                            ACTIVITY="Низкая";   ACTIVITY_COLOR="$RED"
    fi

    if   (( DIFF_H < 1 ));     then AGO="только что"
    elif (( DIFF_H < 24 ));    then AGO="$DIFF_H ч. назад"
    elif (( DIFF_H < 24*30 )); then AGO="$(( DIFF_H / 24 )) дн. назад"
    else                            AGO="$(( DIFF_H / 24 / 30 )) мес. назад"
    fi
fi

# ─── Вывод ────────────────────────────────────────────────
echo -e "${BOLD}${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${BLUE}║${NC}  🚀 ${BOLD}GitHub Repository Analyzer${NC}          ${BOLD}${BLUE}║${NC}"
echo -e "${BOLD}${BLUE}╚════════════════════════════════════════╝${NC}"
echo
echo -e "${MAGENTA}📦 Репозиторий:${NC} ${BOLD}${NAME}${NC}"
echo -e "${YELLOW}⭐ Звёзды:${NC}       ${YELLOW}${STARS_F}${NC}  (⭐)"
echo -e "${GREEN}🔀 Форки:${NC}        ${GREEN}${FORKS_F}${NC}   (🔀)"
echo -e "${ISSUES_COLOR}🐛 Open Issues:${NC}  ${ISSUES_COLOR}${ISSUES_F}${NC}    (🐛)"
echo -e "${CYAN}👤 Автор:${NC}        ${CYAN}${AUTHOR}${NC}"
echo -e "${ACTIVITY_COLOR}📊 Активность:${NC}   ${ACTIVITY_COLOR}${ACTIVITY}${NC} (обновлён ${AGO})"
echo