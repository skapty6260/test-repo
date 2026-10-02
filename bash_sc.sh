#!/usr/bin/env bash

GREEN='\033[1;32m'
CYAN='\033[1;36m'
YELLOW='\033[0;33m'
MAGENTA='\033[0;35m'
BLUE='\033[0;34m'
NC='\033[0m'

printf "${GREEN}%s${NC}\n" "Привет, Мир!"
printf "${CYAN}%-22s${NC} ${YELLOW}%s${NC}\n" "Сегодня:" "$(date)"
printf "${CYAN}%-22s${NC} ${MAGENTA}%s${NC}\n" "Текущий пользователь:" "$USER"
printf "${CYAN}%-22s${NC} ${BLUE}%s${NC}\n" "Мы в директории:" "$(pwd)"