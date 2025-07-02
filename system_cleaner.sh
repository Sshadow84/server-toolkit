#!/bin/bash

LOGO_URL="https://raw.githubusercontent.com/Sshadow84/server-toolkit/main/logo_new.sh"
TMP_LOGO="/tmp/logo_new.sh"

curl -sL "$LOGO_URL" -o "$TMP_LOGO"
if [[ -f "$TMP_LOGO" ]]; then
  source "$TMP_LOGO"
  channel_logo
  rm -f "$TMP_LOGO"
else
  echo "🔕 Логотип не загружен. Продолжаем без логотипа."
fi

confirm() {
    local prompt="$1"
    read -p "$prompt [y/n, Enter = yes]: " choice
    case "$choice" in
        ""|y|Y|yes|Yes) return 0 ;;
        n|N|no|No) return 1 ;;
        *) echo "Пожалуйста, введите y или n."; confirm "$prompt" ;;
    esac
}

check_success() {
    if [ $? -ne 0 ]; then
        echo "❌ Ошибка на этапе: $1"
        exit 1
    fi
}

# Все функции: setup_logrotate, setup_journald, install_rsyslog, clear_logs, clear_docker, delete_archives, clear_cache (оставлены без изменений)

# Перенаправим в подменю
run_safe_mode() {
    setup_logrotate
    setup_journald
    install_rsyslog
    clear_docker
    delete_archives
    clear_cache
}

advanced_menu() {
    while true; do
        echo ""
        echo "🧹  System Cleaner — расширенное меню"
        echo "-------------------------------------"
        echo "1️⃣  Настроить logrotate"
        echo "2️⃣  Настроить journald"
        echo "3️⃣  Установить rsyslog"
        echo "4️⃣  Очистить логи вручную"
        echo "5️⃣  Очистить Docker"
        echo "6️⃣  Удалить архивы"
        echo "7️⃣  Очистить системный кэш"
        echo "8️⃣  Safe Mode (всё сразу)"
        echo "0️⃣  Назад"
        echo "-------------------------------------"
        read -rp "👉 Выберите действие: " choice

        case "$choice" in
            1) setup_logrotate ;;
            2) setup_journald ;;
            3) install_rsyslog ;;
            4) clear_logs ;;
            5) clear_docker ;;
            6) delete_archives ;;
            7) clear_cache ;;
            8) run_safe_mode ;;
            0) break ;;
            *) echo "❌ Неверный выбор. Попробуйте снова." ;;
        esac
    done
}

main_menu() {
    while true; do
        echo ""
        echo "🧰  System Cleaner & Log Manager"
        echo "-------------------------------"
        echo "1️⃣  Быстрая очистка (Safe Mode)"
        echo "2️⃣  Режим для опытных (настройки вручную)"
        echo "0️⃣  Назад в главное меню"
        echo "-------------------------------"
        read -rp "👉 Выберите режим: " top_choice

        case "$top_choice" in
            1) run_safe_mode ;;
            2) advanced_menu ;;
            0) break ;;
            *) echo "❌ Неверный выбор. Попробуйте снова." ;;
        esac
    done
}

main_menu
