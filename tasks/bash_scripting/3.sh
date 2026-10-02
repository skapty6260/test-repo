#!/usr/bin/env bash
set -euo pipefail

CYAN='\033[1;36m'; GREEN='\033[1;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'

read -rp "$(echo -e "${CYAN}Введите целое число: ${NC}")" n

if ! [[ "$n" =~ ^-?[0-9]+$ ]]; then
    echo -e "${RED}Ошибка: нужно целое число.${NC}" >&2
    exit 1
fi

if (( n % 2 == 0 )); then
    echo -e "${GREEN}Число $n — чётное${NC}"
else
    echo -e "${YELLOW}Число $n — нечётное${NC}"
fi