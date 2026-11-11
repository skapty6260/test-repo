#!/bin/bash

# 1. Создаём отдельную сеть (если её ещё нет)
docker network create adminer-net 2>/dev/null

# 2. Запускаем PostgreSQL в этой сети
docker run -d --rm --name temp-postgres \
  --network adminer-net \
  -e POSTGRES_PASSWORD=mysecretpassword \
  postgres:latest

sleep 3

# При выходе останавливаем базу
trap 'docker stop temp-postgres >/dev/null 2>&1' EXIT INT TERM

# 3. Запускаем Adminer в ТОЙ ЖЕ сети
docker run --rm --name temp-adminer \
  --network adminer-net \
  -p 8084:8080 \
  adminer:latest