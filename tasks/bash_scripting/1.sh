#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[1;32m'; CYAN='\033[1;36m'; NC='\033[0m'

read -rp "$(echo -e "${CYAN}Введите ваше имя: ${NC}")" name
echo -e "${GREEN}Привет, ${name}! Добро пожаловать в мир Bash.${NC}"