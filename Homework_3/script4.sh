#!/bin/bash

# Создаем файл со списком пользователей
user_list="users.txt"
cat <<EOF > "$user_list"
user1
user2
user3
admin
guest
EOF

echo "Список пользователей записан в файл $user_list."

# Выводим содержимое файла с нумерацией строк
echo "Содержимое файла с нумерацией строк:"
line_number=1
for user in $(cat "$user_list"); do
  echo "$line_number. $user"
  ((line_number++))
done
