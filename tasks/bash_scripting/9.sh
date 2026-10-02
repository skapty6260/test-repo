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

# ─── Проверка зависимостей ────────────────────────────────
for cmd in curl jq; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo -e "${RED}Ошибка: утилита '$cmd' не установлена.${NC}" >&2
        echo -e "${YELLOW}Установите: sudo apt install $cmd${NC}" >&2
        exit 1
    fi
done

# ─── Проверка аргумента ───────────────────────────────────
if [[ $# -ne 1 ]]; then
    echo -e "${YELLOW}Использование: $0 <owner/repo>${NC}"
    echo -e "${YELLOW}Пример:       $0 tensorflow/tensorflow${NC}"
    exit 1
fi

REPO="$1"

# ─── Запрос к GitHub API ──────────────────────────────────
API_URL="https://api.github.com/repos/${REPO}"
HTTP_CODE=$(curl -s -o /tmp/gh_resp.json -w "%{http_code}" \
    -H "Accept: application/vnd.github+json" \
    "$API_URL")

case "$HTTP_CODE" in
    200) ;;  # OK
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

# ─── Извлечение данных ────────────────────────────────────
NAME=$(jq -r '.full_name'            /tmp/gh_resp.json)
STARS=$(jq -r '.stargazers_count'    /tmp/gh_resp.json)
FORKS=$(jq -r '.forks_count'         /tmp/gh_resp.json)
ISSUES=$(jq -r '.open_issues_count'  /tmp/gh_resp.json)
AUTHOR=$(jq -r '.owner.login'        /tmp/gh_resp.json)
PUSHED=$(jq -r '.pushed_at'          /tmp/gh_resp.json)

# ─── Форматирование чисел с пробелами (182 347) ───────────
fmt() { printf "%'d" "$1" 2>/dev/null || echo "$1"; }
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
PUSH_TS=$(date -d "$PUSHED" +%s 2>/dev/null || echo 0)
NOW_TS=$(date +%s)
DIFF_H=$(( (NOW_TS - PUSH_TS) / 3600 ))

if   (( DIFF_H < 24 ));   then ACTIVITY="Высокая";   ACTIVITY_COLOR="$GREEN"
elif (( DIFF_H < 24*30 )); then ACTIVITY="Средняя";  ACTIVITY_COLOR="$YELLOW"
else                           ACTIVITY="Низкая";   ACTIVITY_COLOR="$RED"
fi

if   (( DIFF_H < 1 ));    then AGO="только что"
elif (( DIFF_H < 24 ));   then AGO="$DIFF_H ч. назад"
elif (( DIFF_H < 24*30 )); then AGO="$(( DIFF_H / 24 )) дн. назад"
else                           AGO="$(( DIFF_H / 24 / 30 )) мес. назад"
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

rm -f /tmp/gh_resp.json