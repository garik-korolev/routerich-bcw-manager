#!/bin/sh

echo "=================================="
echo " RouteRich BCW Manager Installer "
echo "=================================="
echo ""

URL="https://raw.githubusercontent.com/garik-korolev/routerich-bcw-manager/refs/heads/main/blockcheckw-manager.sh"

echo "[1/4] Загрузка..."
wget -O /root/blockcheckw-manager.sh "$URL" || exit 1

echo "[2/4] Права доступа..."
chmod +x /root/blockcheckw-manager.sh

echo "[3/4] Создание команды bcw..."
ln -sf /root/blockcheckw-manager.sh /usr/bin/bcw

echo "[4/4] Готово."
echo ""
echo "Запуск: bcw"
echo ""

bcw
