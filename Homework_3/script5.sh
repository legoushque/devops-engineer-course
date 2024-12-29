cat << 'EOF' > generated_script.sh
#!/bin/bash

# Проверка аргументов
if [[ "$#" -ne 3 ]]; then
  echo "Usage: $0 <количество файлов> <маска имени файлов>"
  exit 1
fi

# Ввод аргументов
num_files=$1
file_mask=$2
lock_file="${0}.lock"

# Проверка существования lock-файла
if [[ -e "$lock_file" ]]; then
  echo "Lock файл существует. Содержимое:"
  cat "$lock_file"
  exit 64
fi

# Создаем lock-файл с PID
echo $$ > "$lock_file"

# Замер времени начала
start_time=$(date +%s)

# Переходим в домашнюю директорию root
cd /root || { echo "Не удалось перейти в /root"; exit 1; }

# Создаем именованный пайп
pipe_file="archive_pipe"
mkfifo "$pipe_file"

# Генерируем файлы
for ((i = 1; i <= num_files; i++)); do
  size=$((RANDOM % 791 + 10))  # Размер от 10 КБ до 800 КБ
  dd if=/dev/urandom of="${file_mask}_${i}.bin" bs=1K count="$size" &>/dev/null
done

# Переходим в /tmp
cd /tmp || { echo "Не удалось перейти в /tmp"; exit 1; }

# Архивируем файлы через именованный пайп
tar -cvf archive.tar - < "$pipe_file" &
find /root -name "${file_mask}_*.bin" -exec cat {} + > "$pipe_file"
rm "$pipe_file"

# Выводим список файлов
ls /root | grep "${file_mask}" | tee file_list.txt

# Выводим время работы
end_time=$(date +%s)
echo "Время выполнения: $((end_time - start_time)) секунд (в формате unixtime: $end_time)"

# Удаляем lock-файл
rm "$lock_file"

EOF
chmod +x generated_script.sh
echo "Скрипт сгенерирован: generated_script.sh"
