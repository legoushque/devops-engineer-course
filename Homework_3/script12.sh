#!/bin/bash

# Проверка наличия входных аргументов
if [ "$#" -ne 2 ]; then
    echo "Использование: $0 <входной файл> <выходной файл>"
    exit 1
fi

INPUT_FILE="$1"
OUTPUT_FILE="$2"

# Проверка существования файлов
if [ ! -f "$INPUT_FILE" ]; then
    echo "Ошибка: входной файл $INPUT_FILE не существует."
    exit 1
fi

if [ -f "$OUTPUT_FILE" ]; then
    echo "Ошибка: выходной файл $OUTPUT_FILE уже существует."
    exit 1
fi

# Обработка строк входного файла
awk 'NR % 2 == 0 {print $0; getline prev; print prev} NR % 2 == 1 {prev=$0}' "$INPUT_FILE" > "$OUTPUT_FILE"

echo "Файл $OUTPUT_FILE успешно создан."
