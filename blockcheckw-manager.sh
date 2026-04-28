cat > /root/blockcheckw-manager.sh <<'EOF'
#!/bin/sh
# BlockCheckW Manager v0.3.5

# Цвета
if [ -t 1 ]; then
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    CYAN='\033[0;36m'
    RED='\033[0;31m'
    BOLD='\033[1m'
    NC='\033[0m'
else
    GREEN=''
    YELLOW=''
    CYAN=''
    RED=''
    BOLD=''
    NC=''
fi

CFG="/root/.bcw.conf"
SELF="/root/blockcheckw-manager.sh"
LINK="/usr/bin/bcw"

pause(){ printf "\n${CYAN}Нажмите Enter...${NC}"; read x; }

save_cfg() {
cat > "$CFG" <<CFGEOF
WORKERS=$WORKERS
PROTO=$PROTO
DOMAINS=$DOMAINS
TIMEOUT=$TIMEOUT
DNS_MODE=$DNS_MODE
CFGEOF
}

init_cfg() {
[ -f "$CFG" ] || cat > "$CFG" <<CFGEOF
WORKERS=128
PROTO=tls12
DOMAINS=rutracker.org
TIMEOUT=600
DNS_MODE=auto
CFGEOF

. "$CFG"

[ -z "$WORKERS" ] && WORKERS=128
[ -z "$PROTO" ] && PROTO=tls12
[ -z "$DOMAINS" ] && DOMAINS=rutracker.org
[ -z "$TIMEOUT" ] && TIMEOUT=600
[ -z "$DNS_MODE" ] && DNS_MODE=auto

save_cfg
}

status_line() {
printf "${CYAN}${BOLD}Домены:${NC} ${GREEN}$DOMAINS${NC} | ${CYAN}${BOLD}Потоки:${NC} ${YELLOW}$WORKERS${NC} | ${CYAN}${BOLD}Протокол:${NC} ${YELLOW}$PROTO${NC} | ${CYAN}${BOLD}Таймаут:${NC} ${YELLOW}$TIMEOUT${NC}\n"
}

install_bcw() {
clear
printf "${CYAN}${BOLD}=========================================${NC}\n"
printf "${CYAN}${BOLD}  Установка / обновление blockcheckw${NC}\n"
printf "${CYAN}${BOLD}=========================================${NC}\n\n"

cd /tmp || return

printf "${YELLOW}→ Получение информации о последней версии...${NC}\n"
URL="$(wget -qO- https://api.github.com/repos/rcd27/blockcheckw/releases/latest \
| grep browser_download_url \
| grep linux-arm64.tar.gz \
| head -1 | cut -d '"' -f4)"

if [ -z "$URL" ]; then
    printf "${RED}${BOLD}Ошибка: не удалось получить ссылку для загрузки.${NC}\n"
    pause
    return
fi
printf "${GREEN}✓ Ссылка получена:${NC} ${URL##*/}\n\n"

printf "${YELLOW}→ Подготовка временной директории...${NC}\n"
rm -rf /tmp/bcwtmp
mkdir -p /tmp/bcwtmp
cd /tmp/bcwtmp || return
printf "${GREEN}✓ Готово${NC}\n\n"

printf "${YELLOW}→ Загрузка архива...${NC}\n"
wget --show-progress -O bcw.tar.gz "$URL" 2>&1
if [ $? -ne 0 ]; then
    printf "\n${RED}${BOLD}Ошибка загрузки.${NC}\n"
    pause
    return
fi
printf "${GREEN}✓ Загрузка завершена${NC}\n\n"

printf "${YELLOW}→ Распаковка...${NC}\n"
tar -xzf bcw.tar.gz
if [ $? -ne 0 ]; then
    printf "${RED}${BOLD}Ошибка распаковки.${NC}\n"
    pause
    return
fi
printf "${GREEN}✓ Распаковано${NC}\n\n"

printf "${YELLOW}→ Поиск исполняемого файла...${NC}\n"
BIN="$(find . -type f -name blockcheckw | head -1)"
if [ -z "$BIN" ]; then
    printf "${RED}${BOLD}Файл blockcheckw не найден.${NC}\n"
    pause
    return
fi
printf "${GREEN}✓ Найден:${NC} $BIN\n\n"

printf "${YELLOW}→ Установка в /usr/bin/...${NC}\n"
cp "$BIN" /usr/bin/blockcheckw
chmod +x /usr/bin/blockcheckw
printf "${GREEN}✓ Установлено${NC}\n\n"

printf "${YELLOW}→ Настройка окружения...${NC}\n"
mkdir -p /opt/zapret2/binaries/linux-arm64
if [ -f /opt/zapret2/nfq2/nfqws2 ]; then
    ln -sf /opt/zapret2/nfq2/nfqws2 /opt/zapret2/binaries/linux-arm64/nfqws2
    printf "${GREEN}✓ Симлинк nfqws2 создан${NC}\n"
fi

ln -sf "$SELF" "$LINK"
printf "${GREEN}✓ Симлинк менеджера создан (bcw)${NC}\n\n"

printf "${GREEN}${BOLD}=========================================${NC}\n"
printf "${GREEN}${BOLD}  Установка завершена${NC}\n"
printf "${GREEN}${BOLD}=========================================${NC}\n\n"

VERSION="$($BIN --version 2>/dev/null | head -1)"
if [ -n "$VERSION" ]; then
    printf "${CYAN}Версия:${NC} ${GREEN}$VERSION${NC}\n"
fi

printf "\n${CYAN}Команда запуска:${NC} ${BOLD}bcw${NC}\n"
pause
}

remove_all() {
clear
printf "${YELLOW}Удаление blockcheckw и настроек...${NC}\n"
rm -f /usr/bin/blockcheckw "$LINK" "$CFG"
printf "${GREEN}✓ Удалено${NC}\n"
pause
}

choose_proto() {
clear
echo "1. http"
echo "2. tls12"
echo "3. tls13"
echo "4. всё"
printf "Выбор: "
read A
case "$A" in
1) PROTO=http ;;
2) PROTO=tls12 ;;
3) PROTO=tls13 ;;
4) PROTO=http,tls12,tls13 ;;
*) ;;
esac
save_cfg
}

choose_dns() {
clear
echo "Выберите режим DNS (для запросов blockcheckw, не влияет на роутер):"
echo ""
echo "1. auto (автоопределение, DoH при подмене) - по умолчанию"
echo "2. system (системный DNS роутера)"
echo "3. doh (DNS over HTTPS, Cloudflare)"
echo ""
printf "Выбор: "
read A
case "$A" in
1) DNS_MODE=auto ;;
2) DNS_MODE=system ;;
3) DNS_MODE=doh ;;
*) ;;
esac
save_cfg
printf "\n${GREEN}✓ DNS режим установлен: ${YELLOW}%s${NC}\n" "$DNS_MODE"
pause
}

settings_menu() {
while true
do
clear
printf "${CYAN}${BOLD}==================================${NC}\n"
printf "${CYAN}${BOLD} Настройки${NC}\n"
printf "${CYAN}${BOLD}==================================${NC}\n"
echo "1. Потоки ($WORKERS)"
echo "2. Протокол ($PROTO)"
echo "3. Таймаут ($TIMEOUT)"
echo "4. Ввести / изменить домены"
echo "5. Показать домены"
echo "6. Очистить домены"
echo "7. DNS режим ($DNS_MODE)"
echo "0. Назад"
printf "${CYAN}${BOLD}==================================${NC}\n"
printf "Выбор: "
read S

case "$S" in
1) printf "Потоки: "; read WORKERS; [ -z "$WORKERS" ] && WORKERS=128; save_cfg ;;
2) choose_proto ;;
3) printf "Таймаут: "; read TIMEOUT; [ -z "$TIMEOUT" ] && TIMEOUT=600; save_cfg ;;
4) printf "Домены: "; IFS= read -r DOMAINS; [ -z "$DOMAINS" ] && DOMAINS=rutracker.org; save_cfg ;;
5) printf "${GREEN}%s${NC}\n" "$DOMAINS"; pause ;;
6) DOMAINS=rutracker.org; save_cfg; printf "${GREEN}Домены сброшены.${NC}\n"; pause ;;
7) choose_dns ;;
0) return ;;
esac
done
}

# Проверка статуса zapret2 (возвращает 0 если запущен, 1 если остановлен)
is_zapret_running() {
    if [ -x /etc/init.d/zapret2 ]; then
        /etc/init.d/zapret2 status 2>/dev/null | grep -q "running" && return 0
    fi
    pgrep -f "nfqws" >/dev/null 2>&1 && return 0
    pgrep -f "tpws" >/dev/null 2>&1 && return 0
    return 1
}

# Остановка zapret2 (принудительная)
zapret_stop_force() {
    if [ -x /etc/init.d/zapret2 ]; then
        /etc/init.d/zapret2 stop >/dev/null 2>&1
        sleep 1
    fi
    pkill -f "nfqws" 2>/dev/null
    pkill -f "tpws" 2>/dev/null
    sleep 1
}

# Запуск zapret2
zapret_start() {
    if [ -x /etc/init.d/zapret2 ]; then
        /etc/init.d/zapret2 start >/dev/null 2>&1
        sleep 2
    fi
}

cleanup_logs() {
clear
printf "${CYAN}${BOLD}=========================================${NC}\n"
printf "${CYAN}${BOLD}  Очистка логов и отчётов${NC}\n"
printf "${CYAN}${BOLD}=========================================${NC}\n\n"

QUICK_COUNT=$(ls -1 /root/*_quick.txt 2>/dev/null | wc -l)
WORKING_COUNT=$(ls -1 /root/*_working.txt 2>/dev/null | wc -l)
JSON_COUNT=$(ls -1 /root/*_report.json 2>/dev/null | wc -l)
SCAN_COUNT=$(ls -1 /root/*_scan.json 2>/dev/null | wc -l)
CHECK_COUNT=$(ls -1 /root/*_check.json 2>/dev/null | wc -l)
REPORT_COUNT=$(ls -1 /root/*_report_vanilla.txt 2>/dev/null | wc -l)

TOTAL=$((QUICK_COUNT + WORKING_COUNT + JSON_COUNT + SCAN_COUNT + CHECK_COUNT + REPORT_COUNT))

if [ "$TOTAL" -eq 0 ]; then
    printf "${YELLOW}Нет файлов для удаления.${NC}\n"
    pause
    return
fi

printf "${YELLOW}Найдено файлов:${NC}\n"
printf "  Быстрые отчёты (*_quick.txt): ${CYAN}%s${NC}\n" "$QUICK_COUNT"
printf "  Рабочие стратегии (*_working.txt): ${CYAN}%s${NC}\n" "$WORKING_COUNT"
printf "  JSON отчёты (*_report.json): ${CYAN}%s${NC}\n" "$JSON_COUNT"
printf "  Scan JSON (*_scan.json): ${CYAN}%s${NC}\n" "$SCAN_COUNT"
printf "  Check JSON (*_check.json): ${CYAN}%s${NC}\n" "$CHECK_COUNT"
printf "  Vanilla отчёты (*_report_vanilla.txt): ${CYAN}%s${NC}\n" "$REPORT_COUNT"
printf "\n${RED}${BOLD}Всего: ${TOTAL} файлов${NC}\n\n"

printf "${RED}${BOLD}ВНИМАНИЕ! Все эти файлы будут удалены безвозвратно.${NC}\n"
printf "${YELLOW}Продолжить? (y/N): ${NC}"
read answer

case "$answer" in
    y|Y|yes|Yes|YES)
        rm -f /root/*_quick.txt 2>/dev/null
        rm -f /root/*_working.txt 2>/dev/null
        rm -f /root/*_report.json 2>/dev/null
        rm -f /root/*_scan.json 2>/dev/null
        rm -f /root/*_check.json 2>/dev/null
        rm -f /root/*_report_vanilla.txt 2>/dev/null
        printf "\n${GREEN}✓ Удалено ${TOTAL} файлов.${NC}\n"
        ;;
    *)
        printf "\n${YELLOW}Очистка отменена.${NC}\n"
        ;;
esac
pause
}

run_quick_scan() {
clear
printf "${CYAN}${BOLD}=========================================${NC}\n"
printf "${CYAN}${BOLD}  Быстрый поиск (только сканирование)${NC}\n"
printf "${CYAN}${BOLD}=========================================${NC}\n"
status_line
echo ""

# Сохраняем состояние ДО сканирования
WAS_RUNNING=0
if is_zapret_running; then
    WAS_RUNNING=1
    printf "\n${YELLOW}zapret2 был запущен, останавливаем...${NC}\n"
    zapret_stop_force
    printf "${GREEN}zapret2 остановлен${NC}\n"
else
    printf "\n${CYAN}zapret2 не был запущен.${NC}\n"
fi

printf "\n${CYAN}Нажмите Enter для запуска...${NC}"
read x
clear

printf "${YELLOW}${BOLD}Сканирование...${NC}\n"
echo ""

blockcheckw -w "$WORKERS" scan \
-d "$DOMAINS" \
-p "$PROTO" \
--timeout "$TIMEOUT" \
--dns "$DNS_MODE" \
--top 20 \
--auto

REPORT="$(ls -t *_report_vanilla.txt 2>/dev/null | head -1)"
DATE="$(date +%Y-%m-%d_%H-%M-%S)"
SAFE="$(echo "$DOMAINS" | tr ', ' '_')"
OUTPUT_FILE="/root/${DATE}_${SAFE}_quick.txt"

if [ -f "$REPORT" ]; then
    TOTAL=$(grep "OK vanilla report:" "$REPORT" | head -1 | sed 's/.* \([0-9]\+\) strategies.*/\1/')
    
    {
        echo "========================================="
        echo "  БЫСТРЫЙ ПОИСК (НЕПРОВЕРЕННЫЕ СТРАТЕГИИ)"
        echo "========================================="
        echo "Дата    : $DATE"
        echo "Домен   : $DOMAINS"
        echo "Протокол: $PROTO"
        echo "Потоки  : $WORKERS"
        echo "Таймаут : $TIMEOUT"
        echo "========================================="
        echo ""
    } > "$OUTPUT_FILE"
    
    grep "nfqws2" "$REPORT" | sed 's/^[^:]*: //' | head -20 >> "$OUTPUT_FILE"
    COUNT=$(grep "nfqws2" "$REPORT" | head -20 | wc -l)
    
    printf "\n${GREEN}✓ Отчёт сохранён:${NC} $OUTPUT_FILE\n"
    printf "\n${CYAN}Всего найдено стратегий:${NC} ${YELLOW}%s${NC}\n" "${TOTAL:-$COUNT}"
    printf "${CYAN}Показано в отчёте:${NC} ${YELLOW}%s${NC}\n" "$COUNT"
    
    rm -f "$REPORT"
else
    printf "\n${RED}Отчёт не создан.${NC}\n"
    printf "\n${YELLOW}Возможные причины:${NC}\n"
    printf "  - Домен не резолвится (нет DNS записи)\n"
    printf "  - Домен выдаёт фейковый IP (подмена DNS)\n"
    printf "  - Проблемы с сетью\n"
fi

# Восстанавливаем состояние ПОСЛЕ сканирования
if [ "$WAS_RUNNING" = "1" ]; then
    printf "\n${YELLOW}Восстанавливаем zapret2...${NC}\n"
    zapret_start
    printf "${GREEN}zapret2 запущен${NC}\n"
else
    # Если изначально был выключен, проверяем не запустился ли он случайно
    if is_zapret_running; then
        printf "\n${YELLOW}zapret2 случайно запустился, останавливаем...${NC}\n"
        zapret_stop_force
        printf "${GREEN}zapret2 остановлен${NC}\n"
    else
        printf "\n${CYAN}zapret2 не был запущен, пропускаем запуск.${NC}\n"
    fi
fi

printf "\n${GREEN}${BOLD}Быстрый поиск завершён.${NC}\n"
pause
}

run_full_scan() {
clear
printf "${CYAN}${BOLD}=========================================${NC}\n"
printf "${CYAN}${BOLD}  Полный поиск (сканирование + проверка)${NC}\n"
printf "${CYAN}${BOLD}=========================================${NC}\n"
status_line
echo ""

# Сохраняем состояние ДО сканирования
WAS_RUNNING=0
if is_zapret_running; then
    WAS_RUNNING=1
    printf "\n${YELLOW}zapret2 был запущен, останавливаем...${NC}\n"
    zapret_stop_force
    printf "${GREEN}zapret2 остановлен${NC}\n"
else
    printf "\n${CYAN}zapret2 не был запущен.${NC}\n"
fi

printf "\n${CYAN}Нажмите Enter для запуска...${NC}"
read x
clear

printf "${YELLOW}${BOLD}Сканирование...${NC}\n"
blockcheckw -w "$WORKERS" scan \
-d "$DOMAINS" \
-p "$PROTO" \
--timeout "$TIMEOUT" \
--dns "$DNS_MODE" \
--auto

REPORT="$(ls -t *_report_vanilla.txt 2>/dev/null | head -1)"

if [ -z "$REPORT" ]; then
    printf "\n${RED}${BOLD}Домен доступен без обхода или нечего проверять.${NC}\n"
    # Восстанавливаем состояние
    if [ "$WAS_RUNNING" = "1" ]; then
        zapret_start
    fi
    pause
    return
fi

printf "\n${YELLOW}${BOLD}Проверка стратегий...${NC}\n"
echo ""

blockcheckw -w "$WORKERS" check \
--from-file "$REPORT" \
-d "$DOMAINS" \
--dns "$DNS_MODE" \
--auto

DATE="$(date +%Y-%m-%d_%H-%M-%S)"
SAFE="$(echo "$DOMAINS" | tr ', ' '_')"

CHECK_JSON="$(ls -t *_check.json 2>/dev/null | head -1)"

if [ -n "$CHECK_JSON" ]; then
    WORKING=$(sed -n 's/.*"working": *\([0-9]*\).*/\1/p' "$CHECK_JSON" | head -1)
    TOTAL=$(sed -n 's/.*"total": *\([0-9]*\).*/\1/p' "$CHECK_JSON" | head -1)
    
    [ -z "$TOTAL" ] && TOTAL=0
    [ -z "$WORKING" ] && WORKING=0
    
    printf "\n${CYAN}Проверено стратегий:${NC} ${YELLOW}%s${NC}\n" "$TOTAL"
    printf "${CYAN}Рабочих:${NC} ${GREEN}%s${NC}\n" "$WORKING"
    
    if [ "$WORKING" -gt 0 ] 2>/dev/null; then
        OUTPUT_FILE="/root/${DATE}_${SAFE}_working.txt"
        
        echo "=========================================" > "$OUTPUT_FILE"
        echo "  РАБОЧИЕ СТРАТЕГИИ" >> "$OUTPUT_FILE"
        echo "=========================================" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
        
        sed -n '/"args": "/{s/.*"args": "//;s/",$//;s/",.*//;p}' "$CHECK_JSON" | while read line; do
            echo "nfqws2 $line"
        done >> "$OUTPUT_FILE"
        
        printf "\n${GREEN}✓ Стратегии сохранены в:${NC} $OUTPUT_FILE\n"
    else
        printf "\n${RED}Рабочих стратегий не найдено.${NC}\n"
    fi
    
    rm -f "$CHECK_JSON"
else
    printf "\n${RED}JSON отчёт не найден.${NC}\n"
fi

rm -f "$REPORT"

# Восстанавливаем состояние ПОСЛЕ сканирования
if [ "$WAS_RUNNING" = "1" ]; then
    printf "\n${YELLOW}Восстанавливаем zapret2...${NC}\n"
    zapret_start
    printf "${GREEN}zapret2 запущен${NC}\n"
else
    # Если изначально был выключен, проверяем не запустился ли он случайно
    if is_zapret_running; then
        printf "\n${YELLOW}zapret2 случайно запустился, останавливаем...${NC}\n"
        zapret_stop_force
        printf "${GREEN}zapret2 остановлен${NC}\n"
    else
        printf "\n${CYAN}zapret2 не был запущен, пропускаем запуск.${NC}\n"
    fi
fi

printf "\n${GREEN}${BOLD}Полный поиск завершён.${NC}\n"
pause
}

show_results() {
while true
do
clear
printf "${CYAN}${BOLD}=========================================${NC}\n"
printf "${CYAN}${BOLD}  Результаты поиска${NC}\n"
printf "${CYAN}${BOLD}=========================================${NC}\n"
echo ""
echo "1. Показать рабочие стратегии"
echo "2. Показать быстрый отчёт"
echo "3. Очистить все логи и отчёты"
echo "0. Назад"
echo ""
printf "Выбор: "
read S

case "$S" in
1)
    FILE="$(ls -t /root/*_working.txt 2>/dev/null | head -1)"
    if [ -z "$FILE" ]; then
        printf "${RED}Нет файлов с рабочими стратегиями.${NC}\n"
        pause
    else
        clear
        cat "$FILE"
        echo ""
        printf "${CYAN}Файл:${NC} $FILE\n"
        pause
    fi
    ;;
2)
    FILE="$(ls -t /root/*_quick.txt 2>/dev/null | head -1)"
    if [ -z "$FILE" ]; then
        printf "${RED}Нет быстрых отчётов.${NC}\n"
        pause
    else
        clear
        cat "$FILE"
        echo ""
        printf "${CYAN}Файл:${NC} $FILE\n"
        pause
    fi
    ;;
3)
    cleanup_logs
    ;;
0) return ;;
esac
done
}

init_cfg
ln -sf "$SELF" "$LINK"

while true
do
clear
printf "${CYAN}${BOLD}==================================${NC}\n"
printf "${CYAN}${BOLD} BlockCheckW Manager v0.3.5${NC}\n"
printf "${CYAN}${BOLD}==================================${NC}\n"
echo "1. Установить / обновить blockcheckw"
echo "2. Удалить blockcheckw + настройки"
echo "3. Быстрый поиск (только сканирование)"
echo "4. Полный поиск (сканирование + проверка)"
echo "5. Настройки"
echo "6. Показать результаты"
echo "0. Выход"
printf "${CYAN}${BOLD}==================================${NC}\n"
status_line
printf "${CYAN}${BOLD}==================================${NC}\n"
printf "Выбор: "
read N

case "$N" in
1) install_bcw ;;
2) remove_all ;;
3) run_quick_scan ;;
4) run_full_scan ;;
5) settings_menu ;;
6) show_results ;;
0) exit 0 ;;
esac
done
EOF

chmod +x /root/blockcheckw-manager.sh
ln -sf /root/blockcheckw-manager.sh /usr/bin/bcw
bcw
