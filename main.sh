#!/bin/bash

# ===== ЛОГОТИП =====
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

# ===== ГЛАВНОЕ МЕНЮ =====
while true; do
    echo ""
    echo "🛡️  SERVER TOOLKIT"
    echo "---------------------------"
    echo "1️⃣  System Cleaner & Log Manager"
    echo "2️⃣  Fail2ban Manager (SSH)"
    echo "3️⃣  Установить btop++ (графический монитор ресурсов)"
    echo "0️⃣  Выйти"
    echo "---------------------------"
    read -rp "👉 Выберите раздел: " main_choice

    case "$main_choice" in
        1)
            bash <(curl -sL "https://raw.githubusercontent.com/Sshadow84/server-toolkit/main/system_cleaner.sh")
            ;;
        2)
            bash <(curl -sL "https://raw.githubusercontent.com/Sshadow84/server-toolkit/main/fail2ban_manager.sh")
            ;;
        3)
            rm -f /tmp/btop_install_log
            bash <(curl -sL "https://raw.githubusercontent.com/Sshadow84/server-toolkit/main/install_btop.sh")
            echo
            cat /tmp/btop_install_log
            echo
            read -n 1 -s -r -p "Нажмите любую клавишу для возврата в меню..."
            echo
            ;;
        0)
            echo "👋 До свидания!"
            exit 0
            ;;
        *)
            echo "❌ Неверный выбор. Попробуйте снова."
            ;;
    esac
done
