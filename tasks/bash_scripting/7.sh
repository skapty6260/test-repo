#!/usr/bin/env bash
set -euo pipefail

CYAN='\033[1;36m'; GREEN='\033[1;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

read -rp "$(echo -e "${CYAN}Расширение (например, txt, sh, js): ${NC}")" ext
ext="${ext#.}"   # убрать точку, если пользователь её ввёл

mapfile -t files < <(find . -maxdepth 1 -type f -name "*.${ext}" | sort)

if (( ${#files[@]} == 0 )); then
    echo -e "${YELLOW}Файлы с расширением .$ext не найдены.${NC}"
    exit 0
fi

echo -e "${GREEN}Найдено файлов: ${#files[@]}${NC}"
for f in "${files[@]}"; do
    echo "  $f"
done