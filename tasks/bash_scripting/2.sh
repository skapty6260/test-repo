#!/usr/bin/env bash
set -euo pipefail

CYAN='\033[1;36m'; GREEN='\033[1;32m'; RED='\033[0;31m'; NC='\033[0m'

read -rp "$(echo -e "${CYAN}Первое число: ${NC}")" a
read -rp "$(echo -e "${CYAN}Второе число: ${NC}")" b

# Проверка, что введены числа
if ! [[ "$a" =~ ^-?[0-9]+([.][0-9]+)?$ && "$b" =~ ^-?[0-9]+([.][0-9]+)?$ ]]; then
    echo -e "${RED}Ошибка: нужно ввести числа.${NC}" >&2
    exit 1
fi

sum=$(awk "BEGIN {print $a + $b}")
echo -e "${GREEN}Сумма: $a + $b = $sum${NC}"