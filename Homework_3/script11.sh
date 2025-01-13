#!/bin/bash

LOG_FILE="service_checker.log"  # Имя файла для логов

# Проверка входных аргументов
if [ -z "$1" ]; then
    echo "Использование: $0 <PID или имя программы>"
    exit 1
fi

# Определяем, что передано: PID или имя программы
if [[ "$1" =~ ^[0-9]+$ ]]; then
    TARGET_TYPE="PID"
    TARGET=$1
else
    TARGET_TYPE="NAME"
    TARGET=$1
fi

# Функция для записи в лог
log_status() {
    local service_name=$1
    local status=$2
    local timestamp=$(date +"%d-%m-%Y %H-%M-%S")
    echo "$timestamp mySvcChecker: service $service_name [$status]" >> "$LOG_FILE"
}

# Основной цикл проверки
while true; do
    if [ "$TARGET_TYPE" == "PID" ]; then
        # Проверяем наличие процесса по PID
        if ps -p "$TARGET" > /dev/null 2>&1; then
            log_status "$TARGET" "isUP"
        else
            log_status "$TARGET" "isDown"
        fi
    else
        # Проверяем наличие процесса по имени
        if pgrep -x "$TARGET" > /dev/null 2>&1; then
            log_status "$TARGET" "isUP"
        else
            log_status "$TARGET" "isDown"
        fi
    fi
    sleep 5  # Задержка между проверками (в секундах)
done
