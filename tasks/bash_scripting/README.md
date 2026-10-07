# bashScripting

Самостоятельная работа по Bash-программированию.

## 📂 Структура

| Файл   | Задание                                    |
| ------ | ------------------------------------------ |
| `1.sh` | Приветствие по имени                       |
| `2.sh` | Калькулятор суммы двух чисел               |
| `3.sh` | Проверка чётности числа                    |
| `4.sh` | Создание структуры веб-проекта             |
| `5.sh` | Счётчик строк в файле                      |
| `6.sh` | Генератор пароля (8 символов)              |
| `7.sh` | Поиск файлов по расширению                 |
| `8.sh` | GitHub Repository Analyzer (цветной вывод) |

## 🚀 Запуск

```bash
git clone <URL>
cd bashScripting
chmod +x *.sh

./1.sh
./2.sh
# ...
./8.sh tensorflow/tensorflow
```

> ⚠️ В Windows скрипты нужно запускать в **Git Bash** (`sh script.sh`),
> в PowerShell они не работают. Для `8.sh` используйте **Ubuntu WSL**:
> нужны утилиты `curl` и `jq`.

## 🛠 Требования

- **Bash** 4+
- **curl**, **jq** (только для `8.sh`)
- Установка в Ubuntu/WSL:
  ```bash
  sudo apt update && sudo apt install -y curl jq
  ```

## 📊 Пример вывода `8.sh`

```
╔════════════════════════════════════════╗
║  🚀 GitHub Repository Analyzer         ║
╚════════════════════════════════════════╝

📦 Репозиторий: tensorflow/tensorflow
⭐ Звёзды:       182 347  (⭐)
🔀 Форки:        73 891   (🔀)
🐛 Open Issues:  1 847    (🐛)
👤 Автор:        google
📊 Активность:   Высокая (обновлён 2 ч. назад)
```

## Скриншоты работы скриптов

![1-3.sh](/assets/bash_scripts1.png "1-3.sh")

![5-7.sh](/assets/bash_scripts2.png "5-7.sh")

![8.sh](/assets/bash_scripts3.png "8.sh")
