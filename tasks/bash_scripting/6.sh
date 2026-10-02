#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[1;32m'; CYAN='\033[1;36m'; NC='\033[0m'

length=8

# Источник: буквы (A-Z, a-z), цифры и немного спецсимволов
chars='A-Za-z0-9!@#$%^&*()_+'

password=$(LC_ALL=C tr -dc "$chars" < /dev/urandom | head -c "$length")

echo -e "${CYAN}Сгенерированный пароль (${length} символов):${NC}"
echo -e "${GREEN}${password}${NC}"