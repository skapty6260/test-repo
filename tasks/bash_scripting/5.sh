#!/usr/bin/env bash
set -euo pipefail

CYAN='\033[1;36m'; GREEN='\033[1;32m'; RED='\033[0;31m'; NC='\033[0m'

read -rp "$(echo -e "${CYAN}Путь к файлу: ${NC}")" file

if [[ ! -f "$file" ]]; then
    echo -e "${RED}Файл '$file' не найден.${NC}" >&2
    exit 1
fi

lines=$(wc -l < "$file")
echo -e "${GREEN}Файл '$file' содержит $lines строк.${NC}"