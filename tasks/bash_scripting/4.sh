#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[1;32m'; CYAN='\033[1;36m'; RED='\033[0;31m'; NC='\033[0m'

read -rp "$(echo -e "${CYAN}Имя проекта: ${NC}")" project

if [[ -z "$project" ]]; then
    echo -e "${RED}Имя не может быть пустым.${NC}" >&2
    exit 1
fi

if [[ -e "$project" ]]; then
    echo -e "${RED}Каталог '$project' уже существует.${NC}" >&2
    exit 1
fi

mkdir -p "$project/css" "$project/js"

cat > "$project/index.html" <<'EOF'
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <title>My Project</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <h1>Hello, World!</h1>
    <script src="js/script.js"></script>
</body>
</html>
EOF

cat > "$project/css/style.css" <<'EOF'
body {
    font-family: sans-serif;
    margin: 2rem;
}
EOF

cat > "$project/js/script.js" <<'EOF'
console.log("Hello from script.js");
EOF

echo -e "${GREEN}Проект '$project' создан:${NC}"
find "$project" | sed 's|[^/]*/|  |g'