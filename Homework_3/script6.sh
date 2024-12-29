#!/bin/bash

# Telegram API токен и ID чата (замените на свои значения)
TELEGRAM_TOKEN="your_telegram_bot_token"
CHAT_ID="your_chat_id"

# Функция для вывода помощи
usage() {
  echo "Usage: $0 [-h] [-p PERCENT]"
  echo "  -h            Show help message"
  echo "  -p PERCENT    Set the threshold percentage for free space"
  exit 1
}

# Парсинг аргументов
while getopts "hp:" opt; do
  case $opt in
    h) usage ;;
    p) THRESHOLD=$OPTARG ;;
    *) usage ;;
  esac
done

# Проверка аргумента THRESHOLD
if [[ -z "$THRESHOLD" || ! "$THRESHOLD" =~ ^[0-9]+$ ]]; then
  echo "Error: Invalid or missing percentage threshold"
  usage
fi

# Проверка размеров разделов
df -h --output=target,pcent | tail -n +2 | while read -r mount_point free_space; do
  # Убираем символ '%' из значения свободного места
  free_space=${free_space%\%}

  # Проверяем, если свободного места меньше указанного порога
  if (( free_space < THRESHOLD )); then
    message="Warning: Free space on $mount_point is below $THRESHOLD%. Currently: $free_space% free."
    
    # Отправляем сообщение в Telegram
    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage" \
      -d chat_id="${CHAT_ID}" \
      -d text="${message}"
  fi
done
