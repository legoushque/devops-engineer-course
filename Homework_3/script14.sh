#!/bin/bash

LOGFILE="/var/log/60port_listener.log"
PORT=60

# Перевод SELinux в Permissive режим
if sestatus | grep -q "enabled"; then
    echo "Switching SELinux to Permissive mode..."
    sudo setenforce 0
fi

# Функция записи лога
log_entry() {
    local client_ip=$1
    local command=$2
    local result=$3
    local timestamp=$(date +"%Y-%m-%d %H-%M-%S")
    local pid=$$
    echo "$timestamp $pid $HOSTNAME $client_ip $command $result" >> $LOGFILE
}

# Старт сервера
echo "Listening on port $PORT..."
while true; do
    # Ожидание подключения клиента
    nc -l -p $PORT -c 'bash -c "
        echo Welcome to the 60-port listener server!
        while true; do
            read command
            case \$command in
                getDate)
                    result=\$(date +\"%Y-%m-%d %H-%M-%S\")
                    echo \$result
                    ;;
                getEpoch)
                    result=\$(date +\"%s\")
                    echo \$result
                    ;;
                getInetStats)
                    result=\$(cat /proc/net/dev)
                    echo \"Network Statistics:\n\$result\"
                    ;;
                getInetStats\ *)
                    iface=\${command#getInetStats }
                    if [[ -d /sys/class/net/\$iface ]]; then
                        result=\$(cat /proc/net/dev | grep \"\$iface\")
                        echo \"Statistics for \$iface:\n\$result\"
                    else
                        result=\"Interface \$iface not found.\"
                        echo \$result
                    fi
                    ;;
                bye)
                    result=\"Session closed.\"
                    echo \$result
                    break
                    ;;
                *)
                    result=\"Invalid command.\"
                    echo \$result
                    ;;
            esac
            client_ip=\$(echo \$SSH_CLIENT | awk '{print \$1}')
            log_entry \"\$client_ip\" \"\$command\" \"\$result\"
        done
    "'
done
