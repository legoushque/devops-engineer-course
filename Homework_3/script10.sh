#!/bin/bash

# Файл с данными о пользователях
USER_FILE="users.txt"

# Функция для вывода информации о пользователе
show_user() {
    local userName=$1
    grep -w "^$userName" "$USER_FILE" | while IFS=" " read -r name creationDate deletionDate homeDir; do
        echo "Имя пользователя: $name"
        echo "Дата создания: $(date -d @$creationDate)"
        if [ "$deletionDate" == "-" ]; then
            echo "Дата удаления: не удалён"
        else
            echo "Дата удаления: $(date -d @$deletionDate)"
        fi
        echo "Домашняя директория: $homeDir"
    done
}

# Функция для добавления нового пользователя
create_user() {
    local userName=$1
    local homeDir=$2
    local creationDate=$(date +%s)

    if grep -qw "^$userName" "$USER_FILE"; then
        echo "Ошибка: Пользователь с именем '$userName' уже существует."
        return
    fi

    echo "$userName $creationDate - $homeDir" >> "$USER_FILE"
    echo "Пользователь '$userName' успешно добавлен."
}

# Функция для удаления пользователя
delete_user() {
    local userName=$1
    local deletionDate=$(date +%s)

    if ! grep -qw "^$userName" "$USER_FILE"; then
        echo "Ошибка: Пользователь с именем '$userName' не найден."
        return
    fi

    sed -i "s/^\($userName [^ ]* \)- /\1$deletionDate /" "$USER_FILE"
    echo "Пользователь '$userName' успешно удалён."
}

# Функция для вывода всех пользователей
list_users() {
    local lineNumber=1
    while IFS=" " read -r name creationDate deletionDate homeDir; do
        if [ -n "$name" ]; then
            echo "$lineNumber: $name $(date -d @$creationDate) $( [ "$deletionDate" == "-" ] && echo "не удалён" || date -d @$deletionDate) $homeDir"
            ((lineNumber++))
        fi
    done < "$USER_FILE"
}

# Проверка существования файла
if [ ! -f "$USER_FILE" ]; then
    touch "$USER_FILE"
fi

# Обработка аргументов
case $1 in
    -s)
        if [ -z "$2" ]; then
            echo "Ошибка: Укажите имя пользователя для просмотра."
        else
            show_user "$2"
        fi
        ;;
    -c)
        if [ -z "$2" ] || [ -z "$4" ] || [ "$3" != "-h" ]; then
            echo "Ошибка: Укажите имя пользователя и домашнюю директорию."
            echo "Пример: $0 -c имяПользователя -h путьКДомашнейДиректории"
        else
            create_user "$2" "$4"
        fi
        ;;
    -d)
        if [ -z "$2" ]; then
            echo "Ошибка: Укажите имя пользователя для удаления."
        else
            delete_user "$2"
        fi
        ;;
    -a)
        list_users
        ;;
    *)
        echo "Использование:"
        echo "$0 -s имяПользователя          # Просмотр информации о пользователе"
        echo "$0 -c имяПользователя -h путь # Создание пользователя"
        echo "$0 -d имяПользователя          # Удаление пользователя"
        echo "$0 -a                         # Список всех пользователей"
        ;;
esac
