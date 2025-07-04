#!/bin/bash
# Логировать всё сразу в файл и в stdout
exec > >(tee /tmp/btop_install_log) 2>&1

set -e

echo "📦 Скачиваем последнюю сборку btop++..."
wget -q --show-progress https://github.com/aristocratos/btop/releases/latest/download/btop-x86_64-linux-musl.tbz

echo "📦 Распаковываем архив..."
tar -xvjf btop-x86_64-linux-musl.tbz >/dev/null

cd btop || { echo "❌ Не удалось перейти в папку btop"; exit 1; }

echo "🔧 Устанавливаем btop++..."
sudo make install
echo "✅ Установка завершена"
echo

# Проверка версии
btop --version
echo

# 🧰 Первый запуск для генерации конфига (запускаем btop в фоне, ждем появления файла)
mkdir -p ~/.config/btop
if [ ! -f ~/.config/btop/btop.conf ]; then
    echo "🧰 Первый запуск для генерации конфига..."
    ( btop >/dev/null 2>&1 & )
    for i in {1..10}; do
        sleep 0.5
        if [ -f ~/.config/btop/btop.conf ]; then
            pkill -f "btop"
            break
        fi
        [ "$i" = 10 ] && pkill -f "btop"
    done
fi

# Установка темы Candy (только если конфиг реально есть)
THEME_DIR="/usr/local/share/btop/themes"
if [ -f ~/.config/btop/btop.conf ]; then
    echo "🎨 Включаем тему Candy..."
    sed -i 's/^color_theme = .*/color_theme = "Candy"/' ~/.config/btop/btop.conf
    if [ ! -f "$THEME_DIR/candy.theme" ]; then
        echo "⬇️ Скачиваем тему Candy..."
        sudo mkdir -p "$THEME_DIR"
        sudo wget -q https://raw.githubusercontent.com/aristocratos/btop/main/themes/candy.theme -O "$THEME_DIR/candy.theme"
    fi
else
    echo "⚠️ Не удалось сгенерировать btop.conf, продолжайте вручную при первом запуске btop!"
fi

echo
echo "🚀 Btop++ установлен!"
echo "👉 Для запуска мониторинга: btop"
echo "❌ Для выхода из btop: Ctrl + C"
echo

# Просто завершаем скрипт — всё уже залогировано и cat-ится в main.sh
exit 0