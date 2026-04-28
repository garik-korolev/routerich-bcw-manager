#!/bin/sh

echo "=================================="
echo " Удаление RouteRich BCW Manager "
echo "=================================="
echo ""

echo "[1/3] Удаление команды bcw..."
rm -f /usr/bin/bcw

echo "[2/3] Удаление менеджера..."
rm -f /root/blockcheckw-manager.sh

echo "[3/3] Удаление настроек..."
rm -f /root/.bcw.conf

echo ""
echo "Удалить пользовательские отчёты поиска?"
echo ""
echo "1 - Да"
echo "2 - Нет"
echo ""
printf "Выбор [1/2]: "
read ANS

case "$ANS" in
1)
echo ""
echo "Удаление отчётов..."
rm -f /root/*_working.txt
rm -f /root/*_quick.txt
rm -f /root/*_report.json
rm -f /root/*_scan.json
rm -f /root/*_check.json
rm -f /root/*_report_vanilla.txt
echo "Отчёты удалены."
;;
*)
echo ""
echo "Отчёты сохранены."
;;
esac

echo ""
echo "BCW Manager удалён."
echo ""
