#!/bin/bash

# Проверяем, указан ли путь до блочного устройства
if [[ -z "$1" ]]; then
  echo "Ошибка: Не указан путь до блочного устройства."
  echo "Использование: $0 <путь до блочного устройства>"
  exit 1
fi

block_device="$1"

# Проверяем, существует ли указанное блочное устройство
if [[ ! -b "$block_device" ]]; then
  echo "Ошибка: $block_device не является блочным устройством."
  exit 2
fi

# Проверяем, примонтировано ли устройство
if mount | grep -q "^$block_device"; then
  echo "Устройство $block_device уже примонтировано."
  exit 90
else
  # Создаем временную директорию
  mount_point=$(mktemp -d)
  if [[ $? -ne 0 ]]; then
    echo "Ошибка: Не удалось создать временную директорию."
    exit 3
  fi

  echo "Создана временная директория: $mount_point"

  # Монтируем устройство
  mount "$block_device" "$mount_point"
  if [[ $? -ne 0 ]]; then
    echo "Ошибка: Не удалось примонтировать $block_device к $mount_point."
    rmdir "$mount_point"
    exit 4
  fi

  echo "Устройство $block_device успешно примонтировано к $mount_point."
fi
