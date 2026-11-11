#!/bin/bash
# Временно запустить Nginx, автоматически удалить контейнер при выходе

if ! docker image inspect nginx >/dev/null 2>&1; then
    echo "Ошибка: локальный образ nginx не найден. Сначала выполните docker pull nginx."
    exit 1
fi

# Добавлен параметр -p 8080:80, перенаправляющий порт 80 контейнера на порт 8080 хоста
docker run --rm --name temp-nginx -p 8080:80 nginx