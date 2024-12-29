#!/bin/bash

# Проверка наличия аргумента
if [[ -z "$1" ]]; then
  echo "Usage: $0 <IP_ADDRESS>"
  exit 1
fi

IP_ADDRESS=$1
LOG_FILE="ping_trace.log"

# Проверка доступности IP через ping (3 попытки)
echo "Проверяем доступность $IP_ADDRESS..."
if ping -c 3 -q "$IP_ADDRESS" > /dev/null 2>&1; then
  ACCESSIBLE="Доступен"
else
  ACCESSIBLE="Недоступен"
fi

# Трассировка маршрута
echo "Выполняем трассировку до $IP_ADDRESS..."
TRACE_OUTPUT=$(traceroute -n "$IP_ADDRESS" 2>/dev/null)

# Получение последнего роутера
LAST_ROUTER=$(echo "$TRACE_OUTPUT" | tail -n 1 | awk '{print $2}')

# Запись в лог
{
  echo "------------------------------"
  echo "Дата: $(date)"
  echo "Проверяемый IP: $IP_ADDRESS"
  echo "Доступность: $ACCESSIBLE"
  echo "Трассировка:"
  echo "$TRACE_OUTPUT"
  echo "Последний роутер: $LAST_ROUTER"
  echo "------------------------------"
} >> "$LOG_FILE"

# Вывод на экран
cat "$LOG_FILE"

exit 0
