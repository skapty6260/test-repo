#!/bin/bash
# HTTP-сервер для раздачи файлов с автоудалением контейнера

# 1. Проверяем, есть ли локальный образ nginx:alpine
if ! docker image inspect nginx:alpine >/dev/null 2>&1; then
    echo "Ошибка: локальный образ nginx:alpine не найден."
    echo "Выполните один раз: docker pull nginx:alpine"
    exit 1
fi

# 2. Удаляем старый контейнер с таким именем (если остался от сбоев)
docker rm -f http-server >/dev/null 2>&1

# 3. Создаём тестовый файл в текущей директории
echo "Hello from HTTP server" > test.txt

# 4. Запускаем Nginx в фоне с монтированием текущей папки и автоудалением
#    -d             — в фоне
#    -p 8082:80     — порт 8082 хоста -> порт 80 контейнера
#    -v $(pwd):/usr/share/nginx/html — монтируем текущую папку в веб-корень
#    --rm           — удалить контейнер после остановки
docker run -d --rm --name http-server \
  -p 8082:80 \
  -v "$(pwd):/usr/share/nginx/html" \
  nginx:alpine

# 5. Ждём пару секунд, чтобы сервер запустился
sleep 2

echo "HTTP-сервер запущен: http://localhost:8082/test.txt"
echo "Нажмите Ctrl+C, чтобы остановить и удалить контейнер."

# 6. Ловим Ctrl+C для остановки контейнера (он удалится благодаря --rm)
trap 'echo -e "\nОстанавливаем HTTP-сервер..."; docker stop http-server >/dev/null 2>&1; exit 0' INT TERM

# 7. Держим скрипт активным, чтобы контейнер в фоне не остался без присмотра
while true; do
    sleep 1
done
