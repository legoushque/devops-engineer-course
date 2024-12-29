#!/bin/bash

# Спрашиваем имя пользователя
read -p "Введите имя пользователя: " username

# Проверяем, существует ли пользователь
if ! id "$username" &>/dev/null; then
  echo "Пользователь $username не найден!"
  exit 1
fi

# Получаем информацию о пользователе
user_info=$(getent passwd "$username")
shell=$(echo "$user_info" | cut -d: -f7)
home_dir=$(echo "$user_info" | cut -d: -f6)
uid=$(echo "$user_info" | cut -d: -f3)
groups=$(id -nG "$username")

# Выводим информацию о пользователе
echo "Информация о пользователе:"
echo "UID: $uid"
echo "Домашняя директория: $home_dir"
echo "Шелл: $shell"
echo "Группы: $groups"

# Спрашиваем, что менять
echo "Что вы хотите изменить?"
echo "1. UID"
echo "2. Домашнюю директорию"
echo "3. Группу"
read -p "Введите номер действия (1-3): " action

case $action in
  1)
    # Изменение UID
    read -p "Введите новый UID: " new_uid
    while getent passwd "$new_uid" &>/dev/null; do
      echo "UID $new_uid уже занят. Попробуйте другой."
      read -p "Введите новый UID: " new_uid
    done
    echo "Команда для изменения UID:"
    echo "sudo usermod -u $new_uid $username"
    ;;
  2)
    # Изменение домашней директории
    read -p "Введите новый путь домашней директории: " new_home
    read -p "Переместить содержимое старой директории? (y/n): " move_content
    if [[ $move_content == "y" ]]; then
      echo "Команда для изменения домашней директории с перемещением содержимого:"
      echo "sudo usermod -d $new_home -m $username"
    else
      echo "Команда для изменения домашней директории без перемещения содержимого:"
      echo "sudo usermod -d $new_home $username"
    fi
    ;;
  3)
    # Изменение группы
    echo "Что вы хотите изменить?"
    echo "1. Основную группу"
    echo "2. Дополнительные группы"
    read -p "Введите номер действия (1-2): " group_action
    if [[ $group_action -eq 1 ]]; then
      read -p "Введите название новой основной группы: " new_group
      echo "Команда для изменения основной группы:"
      echo "sudo usermod -g $new_group $username"
    else
      read -p "Введите названия дополнительных групп через запятую: " new_groups
      echo "Команда для изменения дополнительных групп:"
      echo "sudo usermod -G $new_groups $username"
    fi
    ;;
  *)
    echo "Неверный выбор. Завершение работы."
    exit 1
    ;;
esac
