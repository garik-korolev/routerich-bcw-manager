#!/bin/sh

echo "=================================="
echo " Удаление RouteRich BCW Manager "
echo "=================================="
echo ""

echo "[1/4] Удаление команды bcw..."
rm -f /usr/bin/bcw

echo "[2/4] Удаление менеджера..."
rm -f /root/blockcheckw-manager.sh

echo "[3/4] Удаление настроек..."
rm -f /root/.bcw.conf

echo "[4/4] Готово."
echo ""
echo "BCW Manager полностью удалён."
echo ""
