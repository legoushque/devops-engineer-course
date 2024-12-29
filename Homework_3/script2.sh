#!/bin/bash

# Спрашиваем название файла
read -p "Введите название файла (включая путь, если требуется): " filename

# Создаем файл
touch "$filename" 2>/dev/null

# Проверяем успешность создания
if [[ $? -ne 0 ]]; then
  echo "Не удалось создать файл $filename. Проверьте права доступа."
  exit 1
fi

echo "Файл $filename успешно создан."

# Спрашиваем права для файла
read -p "Введите права для файла (в формате chmod, например, 644): " permissions

# Устанавливаем права
chmod "$permissions" "$filename" 2>/dev/null

# Проверяем успешность изменения прав
if [[ $? -ne 0 ]]; then
  echo "Не удалось установить права $permissions для файла $filename. Проверьте ввод."
  exit 1
fi

echo "Права $permissions успешно установлены для файла $filename."
