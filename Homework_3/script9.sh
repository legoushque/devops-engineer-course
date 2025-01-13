#!/bin/bash

# Проверяем, что переданы два аргумента
if [ "$#" -ne 2 ]; then
    echo "Использование: $0 <path> <time>"
    exit 1
fi

# Получаем аргументы
path=$1
time=$2

# Проверяем, существует ли каталог
if [ ! -d "$path" ]; then
    echo "Ошибка: Каталог '$path' не существует."
    exit 1
fi

# Преобразуем <time> в формат timestamp
timestamp=$(date -d "$time" +%s 2>/dev/null)

# Проверяем корректность времени
if [ -z "$timestamp" ]; then
    echo "Ошибка: Некорректный формат времени '$time'."
    exit 1
fi

# Выводим файлы старше заданного времени
echo "Файлы из '$path', старше '$time':"
find "$path" -type f -printf "%T@ %p\n" | awk -v ts="$timestamp" '$1 < ts {print $2}'
