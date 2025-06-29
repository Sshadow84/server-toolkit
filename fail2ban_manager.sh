#!/bin/bash
# Fail2ban Manager: Интерактивная установка, настройка, управление jail для SSH

JAIL_LOCAL="/etc/fail2ban/jail.local"

print_logo() {
    echo -e "\033[0;35m"
    echo -e ' ███████████  ███████████  ███████  '
    echo -e '░░███░░░░░███░░███░░░░░███░░░░░███ '
    echo -e ' ░███    ░███ ░███    ░███   ░███  '
    echo -e ' ░██████████  ░██████████   ███    '
    echo -e ' ░███░░░░░░   ░███░░░░░███ ░░░     '
    echo -e ' ░███         ░███    ░███         '
    echo -e ' █████        █████   █████        '
    echo -e '░░░░░        ░░░░░   ░░░░░         '
    echo -e "\033[0m"
    echo -e "Fail2ban SSH Manager — https://t.me/ProfitNodes_bot"
    echo
}

pause() {
    read -n1 -rsp "Нажмите любую клавишу для продолжения..." key
    echo
}

confirm() {
    read -p "$1 [y/N]: " ans
    [[ "$ans" =~ ^([yY][eE][sS]|[yY])$ ]]
}

install_fail2ban() {
    echo "🔍 Проверка наличия Fail2ban..."
    if dpkg -l | grep -qw fail2ban; then
        echo "⚠️ Fail2ban уже установлен."
    else
        echo "🛠️ Установка Fail2ban..."
        sudo apt update && sudo apt install -y fail2ban
        if [[ $? -eq 0 ]]; then
            echo "✅ Fail2ban установлен."
        else
            echo "❌ Ошибка установки Fail2ban."
            exit 1
        fi
    fi
    sudo systemctl enable --now fail2ban
}

create_jail_local() {
    if [[ ! -f $JAIL_LOCAL ]]; then
        echo -e "Создание базовой конфигурации jail.local..."
        sudo tee $JAIL_LOCAL >/dev/null <<EOL
[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
findtime = 3600
bantime = -1
EOL
        echo "✅ jail.local создан."
    else
        echo "⚠️ jail.local уже существует."
    fi
}

restart_fail2ban() {
    echo "🔄 Перезапуск Fail2ban..."
    sudo systemctl restart fail2ban
    if sudo systemctl is-active --quiet fail2ban; then
        echo "✅ Fail2ban успешно запущен."
    else
        echo "❌ Ошибка: Fail2ban не удалось запустить. Проверьте конфиг."
        exit 1
    fi
}

change_settings() {
    echo "⚙️ Текущие настройки:"
    grep -E "maxretry|findtime|bantime" $JAIL_LOCAL

    read -p "maxretry (попыток до бана) [3]: " maxretry
    read -p "findtime (секунд, период) [3600]: " findtime
    read -p "bantime (секунд, время бана, -1=навсегда) [-1]: " bantime

    maxretry=${maxretry:-3}
    findtime=${findtime:-3600}
    bantime=${bantime:--1}

    sudo sed -i "s/^maxretry *=.*/maxretry = $maxretry/" $JAIL_LOCAL
    sudo sed -i "s/^findtime *=.*/findtime = $findtime/" $JAIL_LOCAL
    sudo sed -i "s/^bantime *=.*/bantime = $bantime/" $JAIL_LOCAL
    echo "✅ Настройки применены."

    restart_fail2ban
}

view_ignoreip() {
    echo "📋 Текущий список ignoreip:"
    grep -m1 "^ignoreip" $JAIL_LOCAL || echo "(не задано)"
}

add_ignoreip() {
    view_ignoreip
    read -p "Введите IP для добавления в ignoreip: " ip
    if grep -q "^ignoreip" $JAIL_LOCAL; then
        if grep -q "$ip" $JAIL_LOCAL; then
            echo "⚠️ Этот IP уже есть в списке."
        else
            sudo sed -i "s/^ignoreip *=.*/& $ip/" $JAIL_LOCAL
            echo "✅ IP $ip добавлен в ignoreip."
        fi
    else
        echo "ignoreip = $ip" | sudo tee -a $JAIL_LOCAL
        echo "✅ ignoreip добавлен в jail.local."
    fi
    restart_fail2ban
}

remove_ignoreip() {
    view_ignoreip
    read -p "Введите IP для удаления из ignoreip: " ip
    if grep -q "^ignoreip" $JAIL_LOCAL && grep -q "$ip" $JAIL_LOCAL; then
        new_ips=$(grep "^ignoreip" $JAIL_LOCAL | sed "s/$ip//g" | tr -s ' ')
        sudo sed -i "s/^ignoreip.*/$new_ips/" $JAIL_LOCAL
        echo "✅ IP $ip удалён из ignoreip."
        restart_fail2ban
    else
        echo "⚠️ IP не найден в списке ignoreip."
    fi
}

unban_ip() {
    sudo fail2ban-client status sshd 2>/dev/null | grep 'Banned IP' || echo "Нет забаненных IP."
    read -p "Введите IP для разблокировки: " ip
    sudo fail2ban-client unban $ip
    echo "✅ IP $ip разблокирован."
}

check_status() {
    echo "ℹ️ Статус jail sshd:"
    sudo fail2ban-client status sshd
}

show_auth_success() {
    sudo grep "Accepted password" /var/log/auth.log | tail -20
}

show_menu() {
    print_logo
    echo "========== Fail2ban Manager =========="
    echo "1. 🛠 Установка и настройка Fail2ban"
    echo "2. ⚙️ Изменить параметры защиты (maxretry, findtime, bantime)"
    echo "3. 🔓 Разблокировать IP"
    echo "4. ➕ Добавить IP в исключения (ignoreip)"
    echo "5. ➖ Удалить IP из исключений"
    echo "6. 📋 Просмотреть ignoreip"
    echo "7. 🔄 Перезапустить Fail2ban"
    echo "8. 📊 Статус jail sshd"
    echo "9. 🔍 Последние успешные входы по SSH"
    echo "0. 🚪 Выход"
    echo "======================================"
    read -p "Выбор: " act
}

while true; do
    show_menu
    case "$act" in
        1)
            install_fail2ban
            create_jail_local
            restart_fail2ban
            ;;
        2)
            change_settings
            ;;
        3)
            unban_ip
            ;;
        4)
            add_ignoreip
            ;;
        5)
            remove_ignoreip
            ;;
        6)
            view_ignoreip
            ;;
        7)
            restart_fail2ban
            ;;
        8)
            check_status
            ;;
        9)
            show_auth_success
            ;;
        0)
            echo "Выход."; exit 0
            ;;
        *)
            echo "❌ Неизвестная команда!"
            ;;
    esac
    pause
done
