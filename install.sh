#!/bin/sh

echo "=================================="
echo " RouteRich BCW Manager Installer "
echo "=================================="
echo

URL="https://raw.githubusercontent.com/dedikar/routerich-bcw-manager/main/blockcheckw-manager.sh"
SCRIPT="/root/blockcheckw-manager.sh"
LINK="/usr/bin/bcw"

echo "[1/4] Загрузка..."
wget -O "$SCRIPT" "$URL" || exit 1

echo "[2/4] Права доступа..."
chmod +x "$SCRIPT" || exit 1

echo "[3/4] Создание команды bcw..."
rm -f "$LINK"
ln -sf "$SCRIPT" "$LINK" || exit 1

echo "[4/4] Обновление кэша..."
# Для BusyBox/ash
hash -r 2>/dev/null || true
# Для bash
rehash 2>/dev/null || true
# Альтернатива: перечитываем profile
. /etc/profile 2>/dev/null || true

echo ""
echo "=================================="
echo " Готово!"
echo "=================================="
echo ""
echo "Запуск: bcw"
echo ""
echo "Примечание: если команда не найдена, выполните:"
echo "  hash -r && bcw"
echo ""
