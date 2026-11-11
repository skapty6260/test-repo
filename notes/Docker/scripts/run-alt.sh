#!/bin/bash
# Запуск Alt Linux с автоматическим удалением контейнера при выходе

# 1. Проверяем, есть ли локальный образ alt:sisyphus
if ! docker image inspect alt:sisyphus >/dev/null 2>&1; then
    echo "Ошибка: локальный образ alt:sisyphus не найден."
    echo "Выполните один раз: docker pull alt:sisyphus"
    exit 1
fi

# 2. На всякий случай удаляем старый контейнер с таким именем (если остался от сбоев)
docker rm -f alt >/dev/null 2>&1

# 3. Запускаем контейнер
#    -t   — псевдо-терминал (нужен для интерактивной работы)
#    -i   — интерактивный режим (чтобы можно было вводить команды)
#    --rm — автоматически удалить контейнер после выхода
docker run -ti --rm --name alt alt:sisyphus /bin/bash
