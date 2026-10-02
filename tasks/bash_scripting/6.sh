#!/usr/bin/env bash
# Без pipefail — иначе SIGPIPE от head ломает скрипт
set -eu

CYAN='\033[1;36m'; GREEN='\033[1;32m'; NC='\033[0m'

length=8

# Диапазоны БЕЗ кавычек + /dev/urandom
password=$(LC_ALL=C tr -dc 'A-Za-z0-9!@#$%^&*()_+' < /dev/urandom | head -c "$length" || true)

echo -e "${CYAN}Сгенерированный пароль (${length} символов):${NC}"
echo -e "${GREEN}${password}${NC}"